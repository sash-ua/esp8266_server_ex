var vw = "view", avw = "auth_view", fEv = true;
window.addEventListener('load', function ( ) {
    var c = getCookie('ssn');
    if(c){
        viewChange('auth',avw, 'main',vw);
        connect({lgn:null, psswrd:null}, c, null);
    } else {
        viewChange(null, null,'auth',avw);
        var authEl = document.getElementById('auth__sbmt');
        authEl.addEventListener('click',hl);
        authEl.addEventListener('keypress', hl);
    }
    
});
function hl ( ev ) {
    var el = ev.srcElement;
    ev.preventDefault();
    var obj = onEventValid();
    if(obj){
        connect(obj, null, el);
    }
}
function viewChange(rm, clss1, stay, clss2){
    if(rm)document.getElementById(rm).classList.remove(clss1);
    if(stay)document.getElementById(stay).classList.add(clss2);
}
function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}
function getCookie(cname) {
    var name = cname + "=";
    var dC = decodeURIComponent(document.cookie);
    var ca = dC.split(';');
    var l = ca.length;
    for(var i = 0; i < l; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return false;
}
function onEventValid(){
    var inpP = document.getElementById('auth__pass'),
        inpL = document.getElementById('auth__login');
    if(validity(inpL) && validity(inpP)) {
        var b = {lgn:inpL.value, psswrd:inpP.value};
        inpL.value='';
        inpP.value='';
        return b;
    } else {
        inpL.value='';
        inpP.value='';
        return false;
    }
}
function connect(obj, c, el){
    var socket = new WebSocket("ws://192.168.4.1:80");
    var state, ssn = c;
    var op = socket.addEventListener("open", function ( ) {
        c ? socket.send(JSON.stringify({ssn: c, time: new Date().getTime()}))
            : socket.send(JSON.stringify({hash:hash(obj.psswrd+obj.lgn), time: new Date().getTime()}));
    });
    socket.addEventListener("message",function(ev) {
        var inData = JSON.parse(ev.data);
        if(inData.msg){
            showMsg( document.getElementById('errors'), vw, inData.msg, 0 );
        } else if(inData.ssn) {
            document.getElementById('errors').innerText='';
            viewChange('auth',avw, 'main',vw);
            setCookie('ssn', inData.ssn, inData.ssnDrtn);
            ssn=inData.ssn;
            if(el){
                el.removeEventListener('click', hl);
                el.removeEventListener('keypress', hl);
            }
        } else if(inData.ssn === 0 || inData.rld === 1){
            if(inData.ssn === 0){setCookie('ssn', inData.ssn, -1);}
            if(inData.rld === 1){setTimeout(function(){window.location.reload();}, 1000);}
        } else {
            var k;
            for(k in inData){
                inData.hasOwnProperty(k) ? setData(inData, k) : null;
            }
            if(fEv){
                fEv=false;
                listenersHandler('click', function(ev){
                    evHandler(ev, {state: state, ssn:ssn, socket:socket});
                });
                listenersHandler('keypress', function(ev){
                    evHandler(ev, {state: state, ssn:ssn, socket:socket});
                });
            }
        }
    });
    socket.addEventListener("close",function ( ev ) {
        state = ev;
        var str = 'code: ' + ev.code + ' cause: ' + ev.reason;
        errorHandler(str);
        showMsg(
            document.getElementById('errors'),
            vw,
            "Can't connect to the device! Reload page or restart device, check connection and reload page! Code: " + ev.code,
            0
        );
        socket.close();
    });
}
function setTRH( ev, obj) {
    if (ev.type = 'keypress' && ev.key === 'Enter') {ev.preventDefault();}
    var trhv = document.getElementById('trh').innerText,
        inpEl = document.getElementById('aim');
    trhv !== inpEl.value
        ? sendData(obj.state, inpEl, document.getElementById('vldtMsg'), {trh:parseInt( inpEl.value), ssn: obj.ssn, time: new Date().getTime()}, obj.socket)
        : null;
}
function viewToggler( el, clss) {
    el.classList.contains(clss) ? el.classList.remove(clss) : el.classList.add(clss);
}
function setNewPassLog(ev, obj ) {
    ev.preventDefault();
    var b = onEventValid();
    if(b){
        obj.socket.send(JSON.stringify({newhash:hash(b.psswrd+b.lgn), time: new Date().getTime(), ssn: obj.ssn, time: new Date().getTime()}));
        viewChange('auth',avw);
    }
}
function setNewAP(ev, obj ) {
    ev.preventDefault();
    var b = onEventValid();
    if(b){
        obj.socket.send(JSON.stringify({ssid:b.lgn, pass: b.psswrd, ssn: obj.ssn, time: new Date().getTime()}));
        viewChange('auth',avw);
    }
}
function evHandler( ev , obj) {
    var target = ev.target.id;
    var ssid = document.getElementById('auth__ssid');
    var a = document.getElementById('auth');
    switch (true){
        case target === 'change__ap':
            if(ssid.innerText !== 'LogIn'){viewToggler(a, avw);}
            ssid.innerText = 'SSID';
            break;
        case ssid.innerText === 'SSID' && target === 'auth__sbmt':
            setNewAP(ev, obj);
            break;
        case target === 'change__auth':
            if(ssid.innerText !== 'SSID'){viewToggler(a, avw);}
            ssid.innerText = 'LogIn';
            break;
        case ssid.innerText === 'LogIn' && target === 'auth__sbmt':
            setNewPassLog(ev, obj);
            break;
        case target === 'set-trh':
            setTRH(ev, obj);
            break;
        case ev.type === 'keypress' && target === 'aim' && ev.key === 'Enter':
            setTRH(ev, obj);
            break;
        default:0;
            break;
    }
}
function listenersHandler(evType, fn){
    return window.addEventListener(evType,fn);
}
function hash(str, pHash) {
    if (pHash === void 0) { pHash = 2166136261; }
    if (str.length === 0 || !str)
        return null;
    var n = str.length - 1;
    var hash = pHash;
    while (n >= 0) {
        hash ^= str.charCodeAt(n--);
        hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
    }
    return hash;
}
function sendData(glState, targetEl, viewEl, data, socket){
    !glState ? validity(targetEl) ? socket.send(JSON.stringify(data)) : showMsg(viewEl, vw, targetEl.validationMessage, 3000) :null;
}

function setData(obj, id){
    var el = document.getElementById(id);
    el ? el.innerHTML= obj[id] : null;
}
function validity( targetEl ) {
    return targetEl.checkValidity();
}
function errorHandler(str){
    console.log(new Error(str));
}
function showMsg(el, view, msg, d) {
    el.innerText=msg;
    el.classList.add(view);
    if(d){
        var t = setTimeout(function () {
            el.classList.remove(view);
            window.clearTimeout(t);
        },d)
    }
}
