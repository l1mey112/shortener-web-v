// l-m.dev 2022

import anime from 'animejs'
import randomColor from 'randomcolor'

const colors = ['red','orange','pink','purple'];
let randIndex = Math.floor(Math.random() * (colors.length));
function roll(){
    randIndex = Math.floor(Math.random() * (colors.length));
    return randomColor({hue: colors[randIndex],luminosity: 'light'})
}

roll()
const loopcol = randomColor({hue: colors[randIndex],luminosity: 'light'})
document.body.style.backgroundColor = loopcol


anime({
    targets: 'body',
    keyframes: [
        {backgroundColor:roll()},
        {backgroundColor:roll()},
        {backgroundColor:roll()},
        {backgroundColor:roll()},
        {backgroundColor:roll()},
        {backgroundColor:loopcol},
    ],
    duration: 5000,
    easing: 'easeInOutQuart',
    loop: true,
    autoplay:true
});