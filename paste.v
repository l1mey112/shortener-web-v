import vweb
import json
import vredis

import encoding.base64 as bsf
//? actual reliable data format

struct PostPaste {
    text string
	expire int
}

/*

{
	"text":"https://example.com",
	"expire":"300"
}

*/

[post;'/api/p/']
fn (mut app App) set_paste(user string) vweb.Result {
    println("got POST for text")
    if app.req.header.get(.content_type) or {
        app.set_status(400,"")
        return app.text("Content type not specified!")
    } != "application/json" {
        app.set_status(400,"")
        return app.text("JSON content type not specified! (application/json)")
    }   //? bad headers

    paste := json.decode(PostPaste,app.req.data) or {
        app.set_status(418,"")
        return app.text("Cannot parse JSON!")
    }   //? cannot parse

    if paste.expire == 0 {
        app.set_status(418,"")
        return app.text("Cannot use a string value or zero for expire time!\nUse -1 to never expire.")
    }   //? edge case on JSON parsing, string numbers get mapped to 0

    mut redis := vredis.connect(vredis.ConnOpts{}) or {
		app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT CONNECT - POST")
        return app.text("Internal server error, contact me!")
	}   //* connect to redis

    pointer := randthis()
	data := bsf.encode_str(paste.text)

    if !redis.set("p:"+pointer, data) {
        app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT SET DATA - POST")
        return app.text("Internal server error, contact me!")
    }   //? cannot set data

    if paste.expire != -1 {
        redis.expire("p:"+pointer,paste.expire) or {
            app.set_status(500,"")
            eprintln("REDIS ERROR - COULD NOT SET EXPIRY - POST")
            return app.text("Internal server error, contact me!")
        }   //? cannot set expiry
    }

    app.set_status(200,"")
    return app.text('s.l-m.dev/p/$pointer')
    //? s.l-m.dev/l/$pointer
}

[get;"/p/:id"]
fn (mut app App) get_paste(id string) vweb.Result {
    mut redis := vredis.connect(vredis.ConnOpts{}) or {
		app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT CONNECT - POST")
        return app.text("Internal server error, contact me!")
	}   //* connect to redis
    println("got GET")
    println(id)

	data := bsf.decode_str(redis.get("p:"+id) or {
        return app.not_found()
	})

    return app.text(data)
}