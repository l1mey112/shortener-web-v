import vweb

import vredis
import json
import rand
import net.urllib as ulib

fn randthis()string{
    set := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$'()*+,-_~"
	//? set.len = 81
    return rand.string_from_set(set,_idlength)
}

struct PostLink {
    url string
    expire int
}

/*

{
	"url":"https://example.com",
	"expire":"300"
}

*/

[post;'/api/l/']
fn (mut app App) set_link(user string) vweb.Result {
    println("got POST for link")
    if app.req.header.get(.content_type) or {
        app.set_status(400,"")
        return app.text("Content type not specified!")
    } != "application/json" {
        app.set_status(400,"")
        return app.text("JSON content type not specified! (application/json)")
    }   //? bad headers

    link := json.decode(PostLink,app.req.data) or {
        app.set_status(418,"")
        return app.text("Cannot parse JSON!")
    }   //? cannot parse

    if link.expire == 0 {
        app.set_status(418,"")
        return app.text("Cannot use a string value or zero for expire time!\nUse -1 to never expire.")
    }   //? edge case on JSON parsing, string numbers get mapped to 0

    ulib.parse(link.url) or {
        app.set_status(418,"")
        return app.text("Incorrect URL format! Must contain https:// or http://")
    }   //? no sneaky inward URLs

    mut redis := vredis.connect(vredis.ConnOpts{}) or {
		app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT CONNECT - POST")
        return app.text("Internal server error, contact me!")
	}   //* connect to redis

    pointer := randthis()

    if !redis.set("l:"+pointer, link.url) {
        app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT SET DATA - POST")
        return app.text("Internal server error, contact me!")
    }   //? cannot set data

    if link.expire != -1 {
        redis.expire("l:"+pointer,link.expire) or {
            app.set_status(500,"")
            eprintln("REDIS ERROR - COULD NOT SET EXPIRY - POST")
            return app.text("Internal server error, contact me!")
        }   //? cannot set expiry
    }

    app.set_status(200,"")
    return app.text('s.l-m.dev/l/$pointer')
    //? s.l-m.dev/l/$pointer
}

[get;"/l/:id"]
fn (mut app App) get_link(id string) vweb.Result {
    mut redis := vredis.connect(vredis.ConnOpts{}) or {
		app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT CONNECT - POST")
        return app.text("Internal server error, contact me!")
	}   //* connect to redis
    println("got GET")
    println(id)
    return app.redirect(redis.get("l:"+id) or {
        return app.not_found()
    })   //? cannot get data
}