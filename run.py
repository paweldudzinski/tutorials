from bottle import route, run, template, redirect, static_file, view

@route('/static/<filename>')
def server_static(filename):
    return static_file(filename, root='static')

@route('/')
def index():
    return redirect('/erlang-python')

@route('/erlang-python')
@view('erlang_python')
def index():
    return {} 

run(host='127.0.0.1', port=5010)
