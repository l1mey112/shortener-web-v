import vweb

const (
    _idlength = 7
)

struct App {
    vweb.Context
}

fn main() {
    vweb.run(&App{}, 8080)
}


["/"]
fn (mut app App) index() vweb.Result {
    // return app.text('Helloo')
    app.handle_static("templates",true)
	return $vweb.html()
}

/* ["/:path"]
fn (mut app App) serve(path string) vweb.Result {
    // return app.text('Helloo')
    
    return 
} */