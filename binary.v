import vweb
import vredis

import encoding.base64 as bsf
import compress.zlib

/* plain binary

dsddasdarfndaiudbaskdb albd w82g68e1313s
23913gahdajdhba10101001010101010 beep==

~/Downloads/data.zip

*/

//? temporary binary data
//? with a fixed expiry date

[post;'/api/b/']
fn (mut app App) set_binary() vweb.Result {
    println("got POST for binary")
//  if app.req.header.get(.content_type) or {
//      app.set_status(400,"")
//      return app.text("Content type not specified!")
//  } != "application/json" {
//      app.set_status(400,"")
//      return app.text("JSON content type not specified! (application/json)")
//  }   //? bad headers

//  paste := json.decode(PostPaste,app.req.data) or {
//      app.set_status(418,"")
//      return app.text("Cannot parse JSON!")
//  }   //? cannot parse

//  if paste.expire == 0 {
//      app.set_status(418,"")
//      return app.text("Cannot use a string value or zero for expire time!\nUse -1 to never expire.")
//  }   //? edge case on JSON parsing, string numbers get mapped to 0

    if app.req.data.len < 1 {
        app.set_status(418,"")
        return app.text("No data attached!")
    }

    mut data_str := bsf.encode(zlib.compress(app.req.data.bytes()) or {
        app.set_status(500,"")
        return app.text("Internal server error, contact me!")
    })
    // println(app.req.data)
    // println(data_str)
    // return app.text("hello")

    mut redis := vredis.connect(vredis.ConnOpts{}) or {
		app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT CONNECT - POST ")
        eprintln(err)
        return app.text("Internal server error, contact me!")
	}   //* connect to redis

    pointer := randthis()

    if !redis.set("b:"+pointer, data_str) {
        app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT SET DATA - POST ")
        return app.text("Internal server error, contact me!")
    }   //? cannot set data

    redis.expire("b:"+pointer,172800) or {
        app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT SET EXPIRY - POST ")
        eprintln(err)
        return app.text("Internal server error, contact me!")
    }   //? cannot set expiry

    app.set_status(200,"")
    return app.text('s.l-m.dev/b/$pointer')
    //? s.l-m.dev/b/$pointer
}

[get;"/b/:id"]
fn (mut app App) get_binary(id string) vweb.Result {
    mut redis := vredis.connect(vredis.ConnOpts{}) or {
		app.set_status(500,"")
        eprintln("REDIS ERROR - COULD NOT CONNECT - POST ")
        eprintln(err)
        return app.text("Internal server error, contact me!")
	}   //* connect to redis
    println("got GET")
    println(id)

	data := bsf.decode(redis.get("b:"+id) or {
        return app.not_found()
	})

    final := zlib.decompress(data) or {
        app.set_status(500,"")
        return app.text("Internal server error, contact me!")
    }
    app.set_content_type("application/octet-stream")
    return app.ok(final.bytestr())
}