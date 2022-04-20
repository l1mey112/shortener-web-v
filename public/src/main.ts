import './style.css'
import './col.ts'

let ww = window.screen.availWidth; // viewport
/* let wh = window.screen.availWidth; // viewport */

window.addEventListener('resize', function(){
    ww = window.screen.availWidth; // viewport
/*     wh = window.screen.availWidth; // viewport */
});

import anime from 'animejs'
// import randomColor from 'randomcolor'
import $ from 'jquery';

const location = "https://s.l-m.dev/api/"

// l-m.dev 2022

let state = true;
$("#query").val('');

async function handleurl(txt : string){
    
    let exp;
    if ( $( "#ch1" ).is(":checked")) {
        exp = -1; // no expire
    }
    else if( $( "#ch2" ).is(":checked")) {
        exp = 86400; // 1 day
    }
    else if( $( "#ch3" ).is(":checked")) {
        exp = 300; // 5 mins
    }

    let data : any;
    let http = new XMLHttpRequest();

    if (!global_mode) {
        data = {url: txt, expire: exp}
        http.open("POST", location+"l/", true);
    }else{
        data = {text: txt, expire: exp}
        http.open("POST", location+"p/", true);
    }

    http.setRequestHeader('Content-Type', 'application/json');

    http.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            //? hit
            success(this.responseText);
        } else if (this.readyState == 4 && this.status == 418) { 
            //? contact me, 418 json parsing error
            err('misconfigured fronted, contact me!');
        } else if (this.readyState == 4 && this.status == 400) { 
            //? contact me, 400 json parsing error
            err('misconfigured fronted, contact me!');
        } else if (this.readyState == 4 && this.status == 0){
            //? possible server downtime
            //? check the location variable
            err('possible server downtime!');
        } else if (this.readyState == 4 && this.status == 500){
            //? possible server downtime
            //? check the location variable
            err('server internal error, contact me!');
        }
    };

    http.send(JSON.stringify(data))
}

function dobox(){
    if (state){
        $(".out").text('')
        if(!($("#query").val() === '')){
            state = false;
            handleurl(($("#query").val()) as string)
        }else{
            err('must contain http:// or https://')
        }
    }
};

$("#query").on("change keyup paste", function(){
    let text = ($("#query").val()) as string
    if (text.startsWith("https://") || text.startsWith("http://") || text === ''){} else {
        $("#query").val('https://'+text);
    }
})

let global_mode = false
if (global_mode) {
    $(".link1").addClass("none");
    $(".link2").removeClass("none");
}else {
    $(".link2").addClass("none");
    $(".link1").removeClass("none");
}

$("#butt").on("click", function(){
    global_mode = !global_mode

    anime({
        targets: '.content',
        keyframes: [
            {translateX: ww/1.5+100, duration:400},
            {translateX: -ww/1.5+100, duration:0},
            {translateX: 0, duration:400, easing: 'easeOutCubic'}
        ],
        duration: 800,
        easing: 'easeInCubic', // set easing here!
        update: function(anim) {
            if (anim.progress > 50){
                if (global_mode) {
                    $(".link1").addClass("none");
                    $(".link2").removeClass("none");
                }else {
                    $(".link2").addClass("none");
                    $(".link1").removeClass("none");
                }
            }
        }
    });
    if (global_mode){
        $("#entry").css("display", "none");
    }else{
        $("#entry").css("display", "flex");
    }
})

$("#entry").on("submit",function(e){
    e.preventDefault();
    if (global_mode) return
    
    dobox()
});

$("#plain-entry").on("submit",function(e){
    e.preventDefault();
    if (!global_mode) return


    if ($("#text-input").val() === '') return
    $(".out").text('')

    handleurl(($("#text-input").val()) as string)
    $("#text-input").val('')
});

$("#text-input").on("keyup", function(e){
    if (  e.shiftKey && e.ctrlKey && e.key == "Enter") {
        $("#plain-entry").trigger("submit");
    }
})


function success(slim : string){
    copytxt(slim)
    $(".out").text(slim);
    (document.querySelector('#outbox') as HTMLElement).style.boxShadow = "rgb(21, 242, 25) 0px 0px 0px 2px inset";
    $("#query").val('');
    state = true;
}
function err(e : string){
    $("#query").val('');

    (document.querySelector('#outbox')  as HTMLElement).style.boxShadow = "rgba(252, 42, 27, 1) 0px 0px 0px 2px inset";

    $(".out").text(e)
    state = true;
}

function copytxt(txt : string) {
    
    if (!navigator.clipboard){
        console.log('browser does not support clipboard api !')
    } else{
        navigator.clipboard.writeText(txt).then(
            function(){})
        .catch(
            function() {
                console.log('error copying with clipboard api !')
        });
    }  
}