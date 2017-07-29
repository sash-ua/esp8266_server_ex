## Example app. with working HTTP web-server with data exchange through WebSockets (further WS) and authorisation system for Espressif ESP8266.

We know that this microcontroller (further MC) has very small heap (in our case ~41400 bytes) and stable HTTP web-server can't be created. 
But if we use some solution and tricks we can.

#### Postulate.

1. We can't reload page without restart MC, because the server will be out of memory 
(heap after server start is about 7 - 14 kbytes it depends on how much the sensors serving's code is launched).

2. We'd upload HTML (`index.html`, `404.html`), CSS (`common.css`) and JavaScript(`main.js`) files one time. They should be gzipped and further cached in browser.

3. All data exchange should be through WS.

4. Web page changes on the client by JavaScript based on the data obtained by WS.

#### Realization

**Upload**

It's the hardest fase for server. Server should have pre-gzipped files (`index.html.gz`, `404.html.gz`, `common.css.gz`, `main.js.gz`). 
While first download HTTP server sends files, on next they were downloaded from a cache.

**Authorization**

LogIn - length 1-32 letter, digit or underscore.

Password - 8-64 letter, digit or underscore

The server gets hash from client then starts the session and sends an object with session hash (named `ssn`) to save in cookie to the browser.
Session duration is set in `controller.lua` `conf.ssnDrtn` in days.

**NB** ESP8266 haven't real time clock (RTC) in the normal sense of the word. It cannot continue to keep time while the device is off or restarted etc.

Therefore client should send `ssn` and 	`time` to be authorized on the server to perform some actions.

You can change login and password for authorization and access point after log in.

After change authorization's login and password device will automatically restart and reload the browser's page.
After changes for access point you should restart device manually, when you want and pick newly created access point.

**Sensors**

To add sensors you should set it in `getSensors.lua`. And provide data exchange between server and browser by WS. You can add this corresponding code in server's custom section.

#### Instalation

My firmware.
modules: am2320,bit,crypto,file,gpio,i2c,net,node,ow,pwm,sjson,tmr,uart,websocket,wifi
Lua 5.1.4 on SDK 2.1.0(116b762)

Upload all files from `min` dir to device and restart it. Find accesse point `esp` connect with pass `12345678`. 
Go to browser and open `http://192.168.4.1/index.html` login `esp` pass `12345678`

You needn't any sensors connected to the device to work it. 

Thanks for encode and decode functions for WS server to (Tim Caswell)[https://github.com/creationix]


Copyright (c) 2017 Alex Tranchenko. All rights reserved.
MIT License.