<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>Python/Pyramid + Erlang/OTP + MochiWeb + Riak Tutorial</title>
        <link rel="stylesheet" href="/static/style.css" />
        <link href='http://fonts.googleapis.com/css?family=PT+Sans+Narrow:400,700' rel='stylesheet' type='text/css'>
        <!--[if IE]>
        <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
        <script>
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

          ga('create', 'UA-57417277-1', 'auto');
          ga('send', 'pageview');
        </script>
    </head>
    <body>
    
    <section class="container">
    
        <header class="title">
            Python/Pyramid + Erlang/OTP + MochiWeb + Riak
        </header>
        <div class="hr"></div>
        <p>
            The goal of this tutorial is to show how easily you can create a web application that uses Erlang backend for computations and
            database communication (Riak) and light Python frontent (Pyramid is a framework of choice) for data presentation.<br />
            Both Python and Erlang applications are separate beings, two different web servers communicating each other via HTTP using JSON data containers.
        </p>
        <p>
            Erlang/OTP basic knowledge is required. All the resources that you need are here:
            <a target="_blank" href="http://www.learnyousomeerlang.com">www.learnyousomeerlang.com</a><br />
            Python Pyramid framework basic knowledge is required:
            <a target="_blank" href="http://www.pylonsproject.org/projects/pyramid/about">http://www.pylonsproject.org/projects/pyramid/about</a><br />
            Riak very basic knowledge would come in handy
            <a target="_blank" href="http://docs.basho.com/riak/latest/dev/taste-of-riak/erlang/">http://docs.basho.com/riak/latest/dev/taste-of-riak/erlang/</a>
        </p>
        <p>
            Application that we'll create will retrieve all your runs from Endomondo, save it to Riak database and present the charts in web browser.<br />
            If you don't use Endomondo you can sing in there and add fake workouts for the purpose of this tutorial or run few times before you read it ;)<br />
            Let's start then.
        </p>
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a1"></a> 1. Installing MochiWeb and creating a project myruns
        </strong>
        </p>
        <p>
            "MochiWeb is an Erlang library for building lightweight HTTP servers."*<br />
            Here's everything that you need to know about MochiWeb: <a target="_blank" href="http://alexmarandon.com/articles/mochiweb_tutorial/">http://alexmarandon.com/articles/mochiweb_tutorial/</a>.<br />
            Let's follow its steps then. First clone git repo:
            <code>git clone git://github.com/mochi/mochiweb.git</code>
            Then go to mochiweb dir and create project by: 
            <code>make app PROJECT=myruns</code>
            You'll get complete scafold for your project containging <i>rebar.config</i> and start script.<br />
            You can compile and run your app now by invoking <i>make</i> in your <i>myruns</i> directory and run script with <i>./start_script.sh</i><br />
            Check in browser that it works: <i>http://0.0.0.0:8080</i>.<br />
            Works? Great, so let's exit this app (type <i>q().</i>) and check briefly what's under the hood!
            <aside class="footnotes">
                <span>* https://github.com/mochi/MochiWeb</span>
            </aside>
        </p>
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a2"></a> 2. Under the hood of myruns application
        </strong>
        </p>
        
        <p>
            Now we're gonna focus on <i>src/myruns_web.erl</i> file of our MochiWeb project. 
            Let's check <i>loop/2</i> function in this file.<br />
            This is main loop of our app:
        <code>
loop(Req, DocRoot) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;"/" ++ Path = Req:get(path),<br />
&nbsp;&nbsp;&nbsp;&nbsp;try<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case Req:get(method) of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Method when Method =:= 'GET'; Method =:= 'HEAD' -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case Path of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_ -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Req:serve_file(Path, DocRoot)<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'POST' -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case Path of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_ -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Req:not_found()<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_ -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Req:respond({501, [], []})<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end<br />
&nbsp;&nbsp;&nbsp;&nbsp;catch<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...<br />
&nbsp;&nbsp;&nbsp;&nbsp;end.
        </code>
        </p>
        
        <p>
            Loop function gets two parameters - <i>Req</i>, witch is a representation of request and <i>DocRoot</i> points to a directory which is root directory for our webapp.<br />
            <i>"/" ++ Path = Req:get(path)</i> expression gets the path of our request into <i>Path</i>. If request is made from root - <i>Path</i> will contain empty list ([]) otherwise it will containt path without first slash.<br />
            Then method of the request is checked and <i>Path</i> is patternmatched to what we will specific in url. For now everything (_) what is received by GET is processed to <i>Req:serve_file(Path, DocRoot)</i>.<br />
            <i>Req:serve_file(Path, DocRoot)</i> will render index.html file which is in the <i>DocRoot</i> directory in /priv/www/.
        </p>
        
        <p>
            Lets make URL /get_my_runs up and runninng and return a plain text into the browser.<br />
            Essential part of out <i>loop/2</i> will look like that:
            <code>
...<br />
case Req:get(method) of<br />
&nbsp;&nbsp;&nbsp;&nbsp;Method when Method =:= 'GET'; Method =:= 'HEAD' -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case Path of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">"get_my_runs" -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Req:respond({200, [{"Content-Type", "text/plain"}], "Will get my runs..."});</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_ -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Req:serve_file(Path, DocRoot)<br />
&nbsp;&nbsp;&nbsp;&nbsp;end;<br />
...
            </code>
        </p>
        
        <p>
            Compile code (<i>make</i>), run the app (<i>start_script.sh</i>) and check <i>http://0.0.0.0:8080/get_my_runs</i>.<br />
            You should see "Will get my runs..." in your browser.
        </p>
        <p>
            So we have a basic webapp that can handle <i>get_my_runs</i> URL. Now we can start to implement a logic for getting runs from Endomondo.
            But we don't want our data to be processed in <i>loop/2</i> function in our web app. We want our code clean!<br />
            Let's write it in a different module and use Erlang/OTP <i>gen_server</i> behaviour for our purpose!
        </p>
        
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a3"></a>3. Erlang/OTP gen_server behaviour based module as backend
        </strong>
        </p>
        <p>
            We will user <i>gen_server</i> behavour for our backend app.<br />
            Let's start with creating file <i>src/myruns_server.erl</i>
            and paste there gen_server's skeledon that can be found here: <a target="_blank" href="http://spawnlink.com/otp-intro-1-gen_server-skeleton/index.html">http://spawnlink.com/otp-intro-1-gen_server-skeleton/index.html</a>.
        </p>
        <p>
            Modul name should be changed and we will export new function <i>get_my_runs/2</i>:
            <code>
                    -module(myruns_server).<br />
                    ...<br />
                    <span class="blu">-export([start_link/0, get_my_runs/2]).</span>
            </code>
            A new function should be added with it's callback handler:
            <code>
            ...<br />
            <span class="blu">get_my_runs(Username, Password) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, Reply} = gen_server:call(?SERVER, {get_my_runs, Username, Password}),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Reply.</span><br />
            ...<br />
            <span class="blu">handle_call({get_my_runs, Username, _Password}, _From, State) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;Reply = {ok, "Will use " ++ Username ++ " username to connect to Endomondo"},<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{reply, Reply, State};</span><br />
            handle_call(_Request, _From, State) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;Reply = ok,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{reply, Reply, State}.<br />
            ...
            </code>
            
        In the API section of gen_server skeleton we created function <i>get_my_runs/2</i> that requires two parameters: username and password.
        that will be use to connect to endomondo.<br />
        For now we will do nothing special in this function, only return plain text that we want to see in browser. The goal is to start using our module
        in MochiWeb myruns app.
        </p>
        
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a3"></a>4. Running myruns_server as a part of MochiWeb app
        </strong>
        </p>
        <p>
            There are two ways to start <i>myruns_server</i> with MochiWeb <i>myruns</i> application:<br />
            &bull; As a child of myruns supervisor,<br />
            &bull; As an independent application that starts with myruns application.<br />
            The choice is yours. It depends if you need your server within <i>myruns</i> app supervision tree for it to restart after crash or not.<br />
            For purpose of this tutorial let's have <i>myruns_server</i> within <i>myruns</i> supervision tree. To do that you'd need to edit
            <i>myruns_sup.erl</i> file:
            <code>
...<br />
init([]) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;Web = web_specs(myruns_web, 8080),<br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">Server = {myruns_server, {myruns_server, start_link,[]}, permanent, 2000, worker, [myruns_server]},</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;Processes = [Web, <span class="blu">Server</span>],<br />
&nbsp;&nbsp;&nbsp;&nbsp;Strategy = {one_for_one, 10, 10},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{ok, {Strategy, lists:flatten(Processes)}}.<br />
...
            </code>
            So, we've created a child definition for our server and added it to <i>Processes</i> array that is used for defining supervision tree.<br />
            That's it. <i>myruns_server</i> is a part of our application, starts with it and it's supervised by the same supervisor as mochiweb application.
            You can now recomplile, start app again and check in browser if you'll get "Will use some_username username to connect to Endomondo".<br />
            I bet you do, so we can move on to implementing API communication with Endomono.
        </p>
        
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a3"></a>5. Endomondo API in Erlang
        </strong>
        </p>
        <p>
           This will be a separate Erlang module called <i>endomondo_api</i>. I'm not going to explain how to communicate with Endomondo, everything is in the code.
           The goal of this part of tutorial is to show how to get data from some service and save it in Riak database. 
        </p>
        <p>
            So, let's start from building a brand new module. Create a new file <i>endomondo_api.erl</i> and start typing.
        </p>
        <code>
            -module(endomondo_api).<br />
            -export([..]).<br /><br />
            -define(BASE_URL, "https://api.mobile.endomondo.com/mobile/auth?").<br />
            -define(WORKOUTS_URL, "https://api.mobile.endomondo.com/mobile/api/workouts?").<br /><br />
            -define(DEVICE_ID, "46f816fd-be6a-5820-a728-e91c3044f4d8").<br />
            -define(COUNTRY_ID, "PL").<br />
            -define(ACTION, "pair").<br />
        </code>
        <p>
            For now we won't export anything. We just defined few constants:<br />
            &bull; <i>BASE_URL</i> is the REST API URL that we use for authentication in Endomondo. From there we'll get auth token that we'll use to API calls.<br />
            &bull; <i>WORKOUTS_URL</i> is for retrieving actual workouts from Endomondo. In this call we will use auth token that we get from auth call.<br />
            Also we need to define some required constants:<br />
            &bull; <i>DEVICE_ID</i> is an unique Id that will represend your device.<br />
            &bull; <i>COUNTRY_ID</i> is obviously a country of authenticated user.<br />
            &bull; <i>ACTION</i> will have default value "pair".
        </p>
        <p>
            Now, we need a function that will make a request. We'll use <i>httpc</i> module (<a target="_blank" href="http://erlang.org/doc/man/httpc.html">http://erlang.org/doc/man/httpc.html</a>)
        </p>
        <code>
            make_request(URL) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, Resp} = httpc:request(get, {URL, []}, [], []),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{_, _, Body} = Resp,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Body.
        </code>
        <p>
            Request method takes 4 parameters, first is a method (get, post, etc.), second is request in form {url, headers}. For third and fourth parameters check the documentation, we won't need it for our purpose.
            We just need to use <b>get</b> as method and <b>URL</b> without any headers.<br />
            This request will return <i>{ok, Resp}</i> if it will succeed.<br />
            For instance, correct auth API call response result (<i>Resp</i>) will look like that:
        </p>
        <code>
            {<br />&nbsp;&nbsp;&nbsp;&nbsp;{"HTTP/1.1",200,"OK"},<br />
            &nbsp;&nbsp;&nbsp;&nbsp;[{"connection","keep-alive"}, {"date","Wed, 29 Oct 2014 13:35:46 GMT"},<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"server","Apache-Coyote/1.1"}, {"content-length","168"}, <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"content-type","text/plain;charset=UTF-8"}, {"p3p", "CP=\"IDC DSP COR\""},<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"x-ua-compatible","IE=9"}],<br />
            &nbsp;&nbsp;&nbsp;&nbsp;[79,75,10,97,99,116,105,111,110,61,80,65,73,82,69,68,10,97,117,116,104,84,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;111,107,101,110,61,122,67,84,53,117,106,100,53,82,115,67,120,74,65,111,86,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;69,84,106,50,66,119,10,109,101,97,115,117,114,101,61,77,69,84,82,73,67,10,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;100,105,115,112,108,97,121,78,97,109,101,61,80,97,119,101,197,130,32,68,117,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;100,122,105,197,132,115,107,105,10,117,115,101,114,73,100,61,54,50,56,55,49,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;49,55,10,102,97,99,101,98,111,111,107,67,111,110,110,101,99,116,101,100,61,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;116,114,117,101,10,115,101,99,117,114,101,84,111,107,101,110,61,89,82,90,70,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;90,54,83,50,82,117,71,95,45,87,66,113,82,89,121,70,98,81,10]<br />}
        </code>
        <p>
            If you look closely you will notice that this response contains status code, headers and body (this list with numbers is all that matters) and can be pattern matched to this format:
        </p>
        <code>
            {StatusCode, Headers, Body}
        </code>
        <p>
            ...and as we dont need neighter status code nor headers we patternmatch it in a way that's in above function, and return just <i>Body</i>.
        </p>
        <p>
            So let's write a function that will actualy get our auth token.
        </p>
        <code>
            get_token(Email, Password) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;URL = ?BASE_URL ++ "deviceId="++?DEVICE_ID++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&email="++Email++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&password="++Password++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&country="++?COUNTRY_ID++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&action="++?ACTION,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Body = make_request(URL).
        </code>
        <p>
            First we're building the URL. There are four parameters required for that call:<br />
            &bull; <i>email</i> as your Endomondo email<br />
            &bull; <i>password</i> as your Endomondo password<br />
            &bull; <i>country</i>, <i>action</i> and <i>deviceId</i> as explained above<br />
            After calling <i>get_token</i> we will have something like this as a result:
        </p>
        <code>
            [79,75,10,97,99,116,105,111,110,61,80,65,73,82,69,68,10,97,117,116,104,84,111,107,101,110,61,122,67,84,53,
            117,106,100,53,82,115,67,120,74,65,111,86,69,84,106,50,66,119,10,109,101,97,115,117,114,101,61,77,69,84,82,
            73,67,10,100,105,115,112,108,97,121,78,97,109,101,61,80,97,119,101,197,130,32,68,117,100,122,105,197,132,
            115,107,105,10,117,115,101,114,73,100,61,54,50,56,55,49,49,55,10,102,97,99,101,98,111,111,107,67,111,110,
            110,101,99,116,101,100,61,116,114,117,101,10,115,101,99,117,114,101,84,111,107,101,110,61,102,50,49,78,56,
            105,97,73,82,79,75,106,111,56,48,68,51,52,102,87,106,65,10]
        </code>
        <p>
            Uncool! That's because what we see is Erlang's <i>iolist</i>.
            To get something that is more readable we will use <i>iolist_to_binary</i> to convert <i>Body</i>.
            The result of <i>iolist_to_binary(Body)</i> will look like:
        </p>
        <code>
            <<"OK\naction=PAIRED\nauthToken=z0T5ujd5PsCxJAoVETj2Bw\nmeasure=METRIC\ndisplayName=Pawe"...>>
        </code>
        <p>
            Better, but not perfect. It's a binary type that looks more like string. Few lines with raw text and only thing that we need is <i>authToken</i>.
            For that we need to split this data first by "\n", then find a line with authToken and finally split it by "=" and get the value (z0T5ujd5PsCxJAoVETj2Bw).
            The function for that purpose could look like this:
        </p>
        <code>
            split_all(List) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;split_all(List, []).<br />
            split_all(List, Acc) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;[H|T] = binary:split(iolist_to_binary(List), <<"\n">>),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case T of<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[] -> Acc;<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_ -> split_all(T, Acc ++ binary:split(iolist_to_binary(H), <<"=">>))<br />
            &nbsp;&nbsp;&nbsp;&nbsp;end.
        </code>
        <p>
            This simple function uses tail recursion to split our binary data and saves it into a list.<br />
            Let's see what we will get after splitting.
        </p>
        <code>
            [<<"OK">>,<<"action">>,<<"PAIRED">>,<<"authToken">>,<span class="blu"><<"zCT5ujd5RsCxJAoVETj2Bw">></span>,<<"measure">>,<<"METRIC">>,<<"displayName">>,<<80,97,119,101,197,130,32,68,117,100,122,105,197,132,115,107,105>>,<<"userId">>,<<"6287117">>,<<"facebookConnected">>,<<"true">>,<<"secureToken">>,<<"L8bI4YGCR5CQwBI5EcO3fQ">>]

        </code>
        <p>
            What we want is 5th element of this list (the blue one). It will be always 5th element with this version of Endomondo API, so we won't do any additional checking and parsing, we will just assume that it's 5th element and that's it.<br />
            To get this element we will use function <i>lists:nth/2</i> and out final version of <i>get_token/2</i> function will look like that:
        </p>
        <code>
            get_token(Email, Password) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;URL = ?BASE_URL ++ "deviceId="++?DEVICE_ID++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&email="++Email++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&password="++Password++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&country="++?COUNTRY_ID++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&action="++?ACTION,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Body = make_request(URL),<br />
            <span class="blu">&nbsp;&nbsp;&nbsp;&nbsp;Result = split_all(Body),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;binary_to_list(lists:nth(5, Result)).</span><br />
        </code>
        <p>
            In the last line we use <i>binary_to_list/1</i> to convert data from binary type to a list as in Erlang string is a list.<br />
        </p>
        <p>
            Let's test if this function works. First we have to export it in our module:
        </p>
        <code>
            -module(endomondo_api).<br />
            <span class="blu">-export([get_token]).</span><br />
            -define(BASE_URL, "https://api.mobile.endomondo.com/mobile/auth?").<br />
            ...
        </code>
        <p>
            Before trying to call this function in a shell we have to start <i>inets</i> application as a container for Internet clients and servers and <i>ssl</i> application as our calls are HTTPS.<br />
            Our shell output can look like this:
        </p>
        <code>
            1> c(endomondo_api).<br />
            {ok,endomondo_api}<br />
            2> inets:start().<br />
            ok<br />
            3> ssl:start().<br />
            ok<br />
            4> AuthToken = endomondo_api:get_token("paweldudzinski@gmail.com", "***").<br />
            "zCT5ujd5RsVb9AoVETj2Bw"
        </code>
        <p>
            There we go! We have auth token so we can perform calls to get or put workouts from or to Endomondo.<br />
            So let's do it ;) Now it's time for a function that will get workouts from Endomondo using our fresh auth token.<br />
            It will look simmilar to <i>get_token/2</i>:
        </p>
        <code>
            <span class="blu">-export([get_workouts/2]).</span><br />
            ...<br />
            get_workouts(Email, Password) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;TOKEN = get_token(Email, Password),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;URL = ?WORKOUTS_URL ++ "authToken=" ++ TOKEN ++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&fields=device,simple,basic" ++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&maxResults=2" ++<br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&language=en",<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Body = make_request(URL),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Body.<br />
        </code>
        <p>
            <i>get_workouts/2</i> will be our only exported function and <i>get_token/2</i> will become "private" one as it's called within <i>get_workouts/2</i>.
            You may think that in this case everytime we call <i>get_workouts/2</i> the token is retrieved all over again. Well... you can improve this code
            and save token for instance to ETS table and reuse it within <i>get_workouts/2</i> function.<br />
            For the sake of this tutorial we will stick with solution that doesn't store token.
            Let's test it!
        </p>
        <code>
            1>  c(endomondo_api).<br />
            {ok,endomondo_api}<br />
            2> inets:start().<br />
            ok<br />
            3> ssl:start().<br />
            ok<br />
            4> Workouts = endomondo_api:get_workouts("paweldudzinski@gmail.com", "***").<br />
            [123,34,100,97,116,97,34,58,91,123,34,115,112,111,114,116,<br />
             34,58,48,44,34,100,101,115,99,101,110,116,34|...]<br />
        </code>
        <p>
            We got iolist that represents our workouts json. To see it in a more decent way you cast it to binary:
        </p>
        <code>
            6> iolist_to_binary(Workouts).<br />
            <<"{\"data\":[{\"sport\":0,\"descent\":79,\"privacy_workout\":0,\"ascent\":142,\"id\":432671945,\"distance\":5.00872,\"duration\":1797."...>>
        </code>
        <p>
            Let's assume that we don't need all the data like "descend" or "ascend". All that matters is workout id that will be the key in riak database bucket,
            workout name, distance, duration and sport type (as json value). That's why we have to decode this workouts json and redo it to fit our needs.<br />
            Mochiweb modules will come in handy:
        </p>
        <code>
            {struct, DataList} = mochijson2:decode(Workouts).<br />
            {<<"data">>, Data} = lists:nth(1, DataList).
        </code>
        <p>
            <i>mochijson2:decode/1</i> will convert json to erlang struct. If you'll print the result of this decoding you will notice that
            this patternmatching make sens and the 1st item of <i>DataList</i> is the structure that we need, so in <i>Data</i> variable we will have:
        </p>
        <code>
[{struct,[{<<"sport">>,0},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"descent">>,79},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"privacy_workout">>,0},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"ascent">>,142},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"id">>,432671945},<br />
&nbsp;&nbsp;&nbsp;&nbsp;...<br />
 {struct,[{<<"sport">>,0},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"descent">>,65},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"privacy_workout">>,0},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"ascent">>,25},<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"id">>,431834262},<br />
&nbsp;&nbsp;&nbsp;&nbsp;...
        </code>
        <p>
            That's something! Now we have all data we need. Let's wrap up above steps in a new function:
        </p>
        <code>
get_data(Email, Password) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;inets:start(),<br />
&nbsp;&nbsp;&nbsp;&nbsp;ssl:start(),<br /><br />
    
&nbsp;&nbsp;&nbsp;&nbsp;Workouts = get_workouts(Email, Password),<br /><br />
    
&nbsp;&nbsp;&nbsp;&nbsp;inets:stop(),<br />
&nbsp;&nbsp;&nbsp;&nbsp;ssl:stop(),<br /><br />
    
&nbsp;&nbsp;&nbsp;&nbsp;{struct, DataList} = mochijson2:decode(Workouts),<br />
&nbsp;&nbsp;&nbsp;&nbsp;{<<"data">>, Data} = lists:nth(1, DataList),<br />
&nbsp;&nbsp;&nbsp;&nbsp;Data.<br />
        </code>
        <p>
            I don't think there's much to explain. All is clear, isn't it? Of course there's a lot of space to improve the process, feel free to do it.<br />
            At this point we have erlang struct that represents our Endomondo workouts, now we want to save this data to Riak database. As it's a key-value data store,
            our keys will be workout ids and the values will be jsons that will keep sport types, names, distances and workouts' durations.
            To achieve it we have to convert what we have in <i>Data</i> variable into a stucture that will fit to our needs.<br />
            We need a function that will take eache row from <i>Data</i>, convert this data to a target format and saves it to Riak.
        </p>
        <code>
            <span class="blu">-export([save_data/1, get_data/2]).</span><br />
            ...<br />
            save_data(Data) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;lists:map(fun(X) -> save_to_database(X) end, Data).
        </code>
        <p>
            First we have to change our exports. From now on we will need those two functions <i>save_data/1, get_workouts/2</i> as "public" ones.<br />
            <i>save_data/1</i> will process each row of <i>Data</i> list to <i>save_to_database/1</i> function.
            In <i>save_to_database/1</i> function we will deal with each row of <i>Data</i> table (there's a printing of this list somewhere above).
            To get the pure data of this structure we need to patternmatch each row like that:
        </p>
        <code>
            save_to_database(Row, Pid) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{struct, StructList} = Row,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Row.
        </code>
        <p>
            So in a <i>Row</i> variable we will have for instance:
        </p>
        <code>
        [{<<"sport">>,0},<br />
         &nbsp;{<<"descent">>,79},<br />
         &nbsp;{<<"privacy_workout">>,0},<br />
         &nbsp;{<<"ascent">>,142},<br />
         &nbsp;{<<"id">>,432671945},<br />
         &nbsp;{<<"distance">>,5.00872},<br />
         &nbsp;{<<"duration">>,1797.88},<br />
         ...
        </code>
        <p>
            Each row of <i>Data</i> list is a list of tuples. What we need is to convert this list of tuples into two variables. One will represent a key, which is
            a run id (432671945), second a value that should have a json that will contain workout details.<br />
            Sample variables could look like this:
        </p>
        <code>
            Id = 432671945,<br />
            Json = {'distance': 5, 'duration': 10 ... }
        </code>
        <p>
            First we need to extract ID from this list of tuples, so it can be our key for a row in Riak database. My idea how to do it is to recursively go through all elements
            of the list and check if we encountered id, if yes, return the second element of this tuple.
        </p>
        <code>
get_from_list_by_tuple_value(Key, List) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;get_from_list_by_tuple_value(Key, List, 1).<br />
<br />
get_from_list_by_tuple_value(Key, List, Index) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;case Index =< length(List) of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;true -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{FieldName, Value} = lists:nth(Index, List),<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case FieldName of<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Key -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Value;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_ -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;get_from_list_by_tuple_value(Key, List, Index+1)<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end;<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;false -><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;not_found<br />
&nbsp;&nbsp;&nbsp;&nbsp;end.
        </code>
        <p>
            We traverse thrue eache element of the list and check if current <i>FieldName</i> is equal to function parameter <i>Key</i>. The function call for Id will look like this:
        </p>
        <code>
            1> IdValue = endomondo_api:get_from_list_by_tuple_value(<<"id">>, StructList).<br />
            432671945<br />
        </code>
        <p>
            We have our key, which is workout id. Now's time for the value (json). Because json is a unified representation of some collection
            first we have to build this collection, that mochijson2 wants us to call structs:
        </p>
        <code>
create_struct(StructList) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;NameValue = get_from_list_by_tuple_value(<<"name">>, StructList),<br />
&nbsp;&nbsp;&nbsp;&nbsp;SportValue = get_from_list_by_tuple_value(<<"sport">>, StructList),<br />
&nbsp;&nbsp;&nbsp;&nbsp;DistanceValue = get_from_list_by_tuple_value(<<"distance">>, StructList),<br />
&nbsp;&nbsp;&nbsp;&nbsp;DurationValue = get_from_list_by_tuple_value(<<"duration">>, StructList),<br />
<br />
&nbsp;&nbsp;&nbsp;&nbsp;Struct = {struct, [<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Name", NameValue},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Sport", SportValue},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Duraion", DurationValue},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Distance", DistanceValue}]},<br />
&nbsp;&nbsp;&nbsp;&nbsp;Struct.
        </code>
        <p>
            Using our function <i>get_from_list_by_tuple_value/2</i> we extract from each row what we need and create collection recognizable for mochijson2.
            Then this collection has to be "jasonify" in a simple matter:
        </p>
        <code>
            struct_to_json(Struct) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;iolist_to_binary(mochijson2:encode(Struct)).
        </code>
        <p>
            <i>mochijson2:encode/2</i> returns iolist, but we need a binary representation to save to Riak. This way we have keys and a values ready for inserting into database.<br />
            But first, let's test:
        </p>
        <code>
            2> Struct = endomondo_api:create_struct(StructList).<br />
            {struct,[{"Name",<br />
&nbsp;&nbsp;&nbsp;&nbsp;<<87,97,114,115,122,97,119,97,44,32,80,97,114,107,32,83,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;111,119,105,197,132,115,107,105,...>>},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Sport",0},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Duraion",1797.88},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{"Distance",5.00872}]}<br /><br />
            3> Json = endomondo_api:struct_to_json(Struct).<br />
            <<"{\"Name\":\"Warszawa, Park Sowi\\u0144skiego z Samael\",\"Sport\":0,\"Duraion\":1797.88,\"Distance\":5.00872}">>
        </code>
        <p>
            If out manual test passes we can move on and save all data we extract from Endomondo to Riak
        </p>
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a3"></a>6. Saving key-value data to Riak database.
        </strong>
        </p>
        <p>
            Riak is a NoSQL key-value data store that offers extremely high availability, fault tolerance, operational simplicity and scalability. It is my database of choice for the sake of this tutorial with no particular reason.
            If you want to learn which noSQL database should you use for your solutions I encourage you to read this article:
            <a target="_blank" href="http://kkovacs.eu/cassandra-vs-mongodb-vs-couchdb-vs-redis">http://kkovacs.eu/cassandra-vs-mongodb-vs-couchdb-vs-redis</a>.
        </p>
        <p>
            I assume you've installed riak and a node is running. Also you'd need an Erlang Riak connector <i>riak-erlang-client</i> that can be found here:
            <a target="_blank" href="https://github.com/basho/riak-erlang-client">https://github.com/basho/riak-erlang-client</a>.
        </p>
        <p>
            To connect to riak we need database url, port and a bucket where we want to write to. So let's define few makros:
        </p>
        <code>
        -define(RIAK_URL, "127.0.0.1").<br />
        -define(RIAK_PORT, 8087).<br />
        -define(RIAK_BUCKET, <<"endomondo">>).<br />
        </code>
        <p>
            By default your Riak single node will listen on a TCP port 8087. To connect to this node we will write a simple function (let's add function to disconnect as well):
        </p>
        <code>
            connect_to_riak(URL, Port) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, Pid} = riakc_pb_socket:start(URL, Port),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Pid.<br />
            ...<br />
            disconnect_riak(Pid) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;riakc_pb_socket:stop(Pid).
        </code>
        <p>
        As we know how to connect to a Riak database, we'll need a function that can put something there.
        Basic way to do that could look like that:
        </p>
        <code>
            put_to_riak(Pid, Bucket, Key, Json) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;Object = riakc_obj:new(Bucket, Key, Json),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;riakc_pb_socket:put(Pid, Object),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, Key}.
        </code>
        <p>
        First, we need to create a Riak object defined by bucket where we want to write to, key and value (here: <i>Json</i>).
        Then using function <i>riakc_pb_socket:put/2</i> we simply save our object to a database running under <i>Pid</i>.
        </p>
        <p>
        Having those three new function we can extend out old function <i>save_to_database/2</i> defined some time ago:
        </p>
        <code>
            save_data(Data) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;lists:map(fun(X) -> save_to_database(X) end, Data).<br />
            ...<br />
            save_to_database(Row, Pid) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{struct, StructList} = Row,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">IdValue = get_from_list_by_tuple_value(<<"id">>, StructList),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Struct = create_struct(StructList),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Json = struct_to_json(Struct),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, Key} = put_to_riak(Pid, ?RIAK_BUCKET, IdValue, Json),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, saved, Key}.</span>
        </code>
        <p>
            As a reminder, some time ago we wrote a function <i>save_data/1</i> that calls <i>save_to_database/2</i> on each row of <i>Data</i>.
            The "old" version is <i>save_to_database/1</i>, the new one below will be <i>save_to_database/2</i> and second parameter will be the <i>Pid</i> of Riak connection.<br />
            In <i>save_to_database/2</i> first we extract from a row structure to <i>StructList</i>. From that we need <i>Id</i> which will be a key
            and a <i>Json</i> which will be a value. All those functions were already described.<br />
            Finally we put our data to Riak database.
        </p>
        <p>
            Now, let's wrap up function <i>save_data/1</i> with connecting and disconecting to Riak:
        </p>
        <code>
            save_data(Data) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">Pid = connect_to_riak(?RIAK_URL, ?RIAK_PORT),</span><br />
            &nbsp;&nbsp;&nbsp;&nbsp;lists:map(fun(X) -> save_to_database(X, <span class="blu">Pid</span>) end, Data),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">disconnect_riak(Pid),</span><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, saved}.
        </code>
        <p>
            That is it. We know how to get data from Endomondo and save it to Riak! This is how a manual test could look like:
        </p>
        <code>
            $ erl -pa ../deps/mochiweb/ebin/ ../../riak-erlang-client/ebin/  ../../riak-erlang-client/deps/*/ebin<br />
            1> c(endomondo_api).<br />
            &nbsp;&nbsp;&nbsp;{ok,endomondo_api}<br />
            2> Data = endomondo_api:get_data("paweldudzinski@gmail.com", "***").<br />
            &nbsp;&nbsp;&nbsp;[{struct,[{<<"sport">>,0},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<<"descent">>,204},<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...]<br />
            3> endomondo_api:save_data(Data).<br />
        </code>
        <p>
            Additionaly to make sure something is saved to Riak we can easily check it out:
        </p>
        <code>
            4> {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 8087).<br />
            &nbsp;&nbsp;&nbsp;{ok,<0.74.0>}<br />
            5> riakc_pb_socket:list_keys(Pid, <<"endomondo">>).<br />
            &nbsp;&nbsp;&nbsp;{ok,[<<"426742990">>,<<"419648704">>,<<"425824935">>,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<<"420553339">>,<<"434713084">>,<<"420337752">>,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<<"432671945">>,<<"433957938">>,<<"423563766">>,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<<"431074584">>,<<"428770022">>,<<"424958297">>,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<<"436272832">>,<<"420549907">>,<<"428014121">>,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<<"438690639">>,<<"422652298">>,<<"421434564">>,<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<<"429675739">>,<<"431834262">>,<<"422652666">>]}
        </code>
        <p>
            We've got it! The part that is responsible for Endomondo API and database operations is done.
            You can take a look at the final erl file <a href="#">here</a>. Of course it's a very basic and step-by-step approach that can be refactored so please feel free. And feel free to write tests ;)
        </p>
        <div class="hr"></div>
        <p class="subtitle">
        <strong>
            <a name="#a3"></a>7. Seting up a worker in MochiWeb
        </strong>
         </p>
         <p>
             We already have a set of functions that will allow us to get data from Endomondo and save it to Riak. Now we have to set up a worker,
             a process that will be run periodicaly, let's say each 1 hour, that will do some work so out database will be up to date and python application can load all the data we need to a browser.
         </p>
         <p>
             Let's focus on <i>src/myruns_web.erl</i> file of our MochiWeb project. 
         </p>
         <p>
             We need to implement our periodical worker. Perfect solution for that is <i>handle_info/2</i> in our <i>gen_server</i> application.
             It deals with messages that do not fit our interface. Simple code belows will fit our needs.<br />
             First we need to send a message that is not handled in any way in the application, for instance:
         </p>
         <code>
                <span class="blu">-define(INTERVAL, 60000).</span><br />...<br />
                init([]) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">erlang:send_after(?INTERVAL, self(), trigger),</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;{ok, #state{}}.
         </code>
         <p>
             We need to send a message that is nowhere handled. Let's call it <i>trigger</i> that will be send to <i>self()</i> process
             after <i>INTERVAL</i> miliseconds and according to <i>gen_server</i> specification we can handle that in <i>handle_info/2</i> function.
         </p>
         <code>
<span class="blu">
handle_info(trigger, State) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;Data = endomondo_api:get_data("paweldudzinski@gmail.com", "***"),<br />
&nbsp;&nbsp;&nbsp;&nbsp;endomondo_api:save_data(Data),  <br />
&nbsp;&nbsp;&nbsp;&nbsp;erlang:send_after(?INTERVAL, self(), trigger),<br />
&nbsp;&nbsp;&nbsp;&nbsp;{noreply, State};<br /></span>
handle_info(_Info, State) -><br />
&nbsp;&nbsp;&nbsp;&nbsp;{noreply, State}.
         </code>
         <p>
            Using functions that we wrote previously we can get data from Endomondo and save it to Riak. Then yet again send a message <i>trigger</i> after <i>INTERVAL</i> miliseconds and repeat the process.
         </p>
         <p>
             Our worker is done but as usual there is a lot of room to improve. For instance you could try to get rid of hardcoded Endomondo username and password.
         </p>
         <p>
             Last thing we need to change at this piont is MochiWeb's start script (<i>start-dev.sh</i>) for it to use erlang riak client:
         </p>
         <code>
            #!/bin/sh<br />
            exec erl \<br />
&nbsp;&nbsp;&nbsp;&nbsp;-pa ebin deps/*/ebin <span class="blu">../riak-erlang-client/ebin/  ../riak-erlang-client/deps/*/ebin \</span><br />
&nbsp;&nbsp;&nbsp;&nbsp;-boot start_sasl \<br />
&nbsp;&nbsp;&nbsp;&nbsp;-sname myruns_dev \<br />
&nbsp;&nbsp;&nbsp;&nbsp;-s myruns \<br />
&nbsp;&nbsp;&nbsp;&nbsp;-s reloader<br />
         </code>
          <div class="hr"></div>
            <p class="subtitle">
            <strong>
                <a name="#a3"></a>8. Getting data from Riak and serving as JSON
            </strong>
            </p>
            <p>
                As you probably remember in one of first chapters we wrote a simple finction in our gen_server application called <i>get_my_runs/2</i>.
                It had two parameters: username and password. We will skip them both as those credentials are hardcoded in a worker (please feel free to redo the application so it would be somehow possible for user to provide username and password).<br />
                This is how a simple scafold of that functionality should look like now:
            </p>
            <code>
            -export([start_link/0, get_my_runs/0]).<br />
            ...<br />
            get_my_runs() -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;{ok, Reply} = gen_server:call(?SERVER, {get_my_runs}),<br />
            &nbsp;&nbsp;&nbsp;&nbsp;Reply.<br />
            ...<br />
            handle_call({get_my_runs}, _From, State) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;Reply = {ok, "Getting runs"},<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{reply, Reply, State};<br />
            handle_call(_Request, _From, State) -><br />
            &nbsp;&nbsp;&nbsp;&nbsp;Reply = ok,<br />
            &nbsp;&nbsp;&nbsp;&nbsp;{reply, Reply, State}.<br />
            </code>
            <p>
                Compile new code and run MochiWeb. Check if all work fine here: <i>http://0.0.0.0:8080/get_my_runs</i>. After small adjustment in
                <i>myruns_web.erl</i> you should see "Getting runs" in your browser. I'll let you discover what has to be changed in main MochiWeb loop ;)
            </p>
            <p>
                Let's write some code that will serve json with workouts instead on lame "Getting runs":
            </p>
            <code>
                get_workouts() -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;Pid = connect_to_riak(?RIAK_URL, ?RIAK_PORT),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;{ok, Keys} = riakc_pb_socket:list_keys(Pid, <<"endomondo">>),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;Struct = get_workouts_struct(Keys, Pid),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;disconnect_riak(Pid),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;mochijson2:encode(Struct).
            </code>
            <p>
                <i>get_workouts/0</i> first connects to Riak and then gets all available heys in a bucket <<"endomondo">>. This operation is generally 
                not recommended as it might be quite resource consuming as it requires traversing all keys stored in the cluster. But for the sake of this tutorial it's fine.
            </p>
            <p>
                Function <i>get_workouts_struct/2</i> that will return Erlang structures that will be converted to json with <i>mochijson2:encode/1</i>
                has to get all values indicated by keys from database.
                Then should return a list of those objects build using tail recursion:
            </p>
            <code>
                get_workouts_json(Keys, Pid) -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;get_workouts_json(Keys, Pid, []).<br />
                <br />
                get_workouts_json([H|[]], Pid, Acc) -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;Struct = get_row_as_struct(Pid, H),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;Acc ++ [Struct];<br />
                get_workouts_json([H|T], Pid, Acc) -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;Struct = get_row_as_struct(Pid, H),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;get_workouts_json(T, Pid, Acc ++ [Struct]).
            </code>
            <p>
                Accumulator <i>Acc</i> will collect all objects returned by <i>get_row_as_struct/2</i> until it reaches empty lists.
            </p>
            <code>
                get_row_as_struct(Pid, Element) -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;{ok, Row} = riakc_pb_socket:get(Pid, ?RIAK_BUCKET, Element),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;Struct = mochijson2:decode(riakc_obj:get_value(Row)),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;Struct.
            </code>
            <p>
                First a row from database is fetched with <i>riakc_pb_socket:get/3</i> where <i>Element</i> is a workout key.
                Because a value is kept as a string (json) that we retrieve using <i>riakc_obj:get_value/1</i> and eventually we need a list of erlang objects
                we need to convert it back to struct with <i>mochijson2:decode/1</i>.
            </p>
            <p>
                List of Erlang structs is finally served to a browser as json, so we need a small change in <i>myruns_server.erl</i>:
            </p>
            <code>
                handle_call({get_my_runs}, _From, State) -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">Runs = endomondo_api:get_workouts(),<br />
                &nbsp;&nbsp;&nbsp;&nbsp;Reply = {ok, Runs},</span><br />
                &nbsp;&nbsp;&nbsp;&nbsp;{reply, Reply, State};<br />
                handle_call(_Request, _From, State) -><br />
                &nbsp;&nbsp;&nbsp;&nbsp;Reply = ok,<br />
                &nbsp;&nbsp;&nbsp;&nbsp;{reply, Reply, State}.
            </code>
            <p>
                Now we can test <i>http://0.0.0.0:8080/get_my_runs</i> where we should see our json. If so, we're done with Erlang part.
                If you see anything to improve, change, make more flexible etc. feel free to do it and share with me. And write some tests ;)
            </p>
            <div class="hr"></div>
            <p class="subtitle">
            <strong>
                <a name="#a3"></a>8. Python virtualenv nad pyramid project
            </strong>
            </p>
            <p>
                I assume you do have python installed. We'd need a virtual enviroment for our python project:
            </p>
            <code>
                $ easy_install virtualenv<br />
                $ virtualenv myruns_python_env --no-site-packages
            </code>
            <p>
                When we have a basic python virtual enviroment created for our project, we can proceed with installing pylons packages:
            </p>
            <code>
                $ myruns_python_env/bin/easy_install "pyramid==1.5.2"
            </code>
            <p>
                After pyramid is installed we're ready to create a project. Let's call it "myruns_web":
            </p>
            <code>
                myruns_python_env/bin/pcreate -s starter myruns_web
            </code>
            <p>
                Bunch on files will be created. If you'd like to know more on that I strongly advice you to check the documentation.
                After all you can run your pyramid application: <i>../myruns_python_env/bin/pserve development.ini</i>
            </p>
            
            <div class="hr"></div>
            <p class="subtitle">
            <strong>
                <a name="#a3"></a>9. Retrieving data from Erlang application
            </strong>
            </p>
            <p>
                Let's assume that our worker that periodically gets the data from Endomondo and saves it to Riak is up and running under local address:
                <i>http://0.0.0.0:8080</i> and invoking URL <i>http://0.0.0.0:8080/get_my_runs</i> will return json with workouts.<br />
                What we need is to create a view that will get this json, convert it into python dict and show some cool summary.
            </p>
            <p>
                Let's start from routing. We'd need workouts summary to be displayed straight away under <i>http://0.0.0.0:6543/</i>.
                So in <i>__ini__.py</i> we dont have to change anything ;) Let's leave it like it is:
            </p>
            <code>
                def main(global_config, **settings):<br />
                &nbsp;&nbsp;&nbsp;&nbsp;""" This function returns a Pyramid WSGI application.<br />
                &nbsp;&nbsp;&nbsp;&nbsp;"""<br />
                &nbsp;&nbsp;&nbsp;&nbsp;config = Configurator(settings=settings)<br />
                &nbsp;&nbsp;&nbsp;&nbsp;config.include('pyramid_chameleon')<br />
                &nbsp;&nbsp;&nbsp;&nbsp;config.add_static_view('static', 'static', cache_max_age=3600)<br />
                &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">config.add_route('home', '/')</span><br />
                &nbsp;&nbsp;&nbsp;&nbsp;config.scan()<br />
                &nbsp;&nbsp;&nbsp;&nbsp;return config.make_wsgi_app()<br />
            </code>
            <p>
                Line marked with blue colour indicate that "home" view will be responsible for a "/" URL.
                Implementation of this view can be found in a <i>view.py</i> file. Below's a slightly changed version:
            </p>
            <code>
                <span class="blu">@view_config(route_name='home', renderer='templates/index.mako')</span><br />
                def my_view(request):<br />
                &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">return {}</span><br />
            </code>
            <p>
                Our content will be shown in rendered <i>index.mako</i> (which you'd need to create). For now no parameters will be passed to a template.
            </p>
            <p>
                Let's communicate with MochiWeb now.
            </p>
            <code>
                <span class="blu">import json<br />
                import urllib2</span><br />
                from pyramid.view import view_config<br />
                <br />
                @view_config(route_name='home', renderer='templates/index.mako')<br />
                def my_view(request):<br />
                &nbsp;&nbsp;&nbsp;&nbsp;<span class="blu">req = urllib2.Request('http://0.0.0.0:8080/get_my_runs')<br />
                &nbsp;&nbsp;&nbsp;&nbsp;response = urllib2.urlopen(req)<br />
                &nbsp;&nbsp;&nbsp;&nbsp;data = response.read()<br />
                &nbsp;&nbsp;&nbsp;&nbsp;structure = json.loads(data)<br />
                &nbsp;&nbsp;&nbsp;&nbsp;structure = sorted(structure, key=lambda x: x['Date']):<br />
                <br />
                &nbsp;&nbsp;&nbsp;&nbsp;return {<br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'structure': structure<br />
                &nbsp;&nbsp;&nbsp;&nbsp;}</span><br />
            </code>
            <p>
                We would need two extra libraries to gain our goal: <i>json</i> for parsing json to python structure and <i>urllib2</i> for getting a resource from a given URL.
                The body of <i>my_view</i> action is easy to understand. First we fetch content of <i>http://0.0.0.0:8080/get_my_runs</i> which is json.
                Then we convert json to python list and sort this list by a dict key "Data". Finally we return a context with sorted structure and render mako file where we can do anything we need with our workouts.
            </p>
            <p>
                That is basically it. Now you can do all kind of fancy charts, statistics etc with your workouts. Erlang worker will fetch new workouts every X minutes and every request to pyramid app will return 
                brand new structure with current data.
            </p>
            <p>
                Hope you enjoyed it. Feel free to share it and send me your questions, feedback and ideas on how to improve on paweldudzinski@gmail.com.
            </p>
    </section>
    <br /><br /><br /><br />
    </body>
</html>
