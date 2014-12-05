from bottle import route, run, template, redirect, static_file, get_url

@route('/static/:path#.+#', name='static')
def static(path):
    return static_file(path, root='static')

@route('/')
def index():
    return redirect('/erlang-python')

@route('/erlang-python')
@view('erlang_python')
def index():
    return { 'get_url': get_url } 

run(host='127.0.0.1', port=5010)
