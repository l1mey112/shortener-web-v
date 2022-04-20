import net.http

fn test_link(){
	post := http.post_json(
		"http://localhost:8080/api/l/", 
		'{"url": "https://example.com","expire": -1}'
	) or {
		panic("Failed to post! $err")
	}
	id := post.text[12..]
	assert post.status_code == 200
	assert id.len == 7

	get := http.get("http://localhost:8080/l/$id") or {
		panic("Failed to get! $err")
	}

	//! sends redirect,
	//? wait for it to finish

	assert get.status_code == 200
}

fn test_paste(){
	text := "AAAAAAAAAAAAARGH\n\nthisis\r\nths"
	post := http.post_json(
		"http://localhost:8080/api/p", 
		'{"text": "$text","expire": -1}'
	) or {
		panic("Failed to post! $err")
	}
	id := post.text[12..]
	assert post.status_code == 200
	assert id.len == 7

	get := http.get("http://localhost:8080/p/$id") or {
		panic("Failed to get! $err")
	}

	assert get.status_code == 200
	assert get.text == text
}

fn main() {
	test_link()
	println("worked fine!")
	test_paste()
	println("worked fine!")
}