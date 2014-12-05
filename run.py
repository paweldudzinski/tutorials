from bottle import route, run, template, redirect

@route('/erlang-python')
def index():
    return redirect('/erlang-python')

@route('/erlang-python')
def index():
    return template('erlang_python')

run(host='127.0.0.1', port=5010)
