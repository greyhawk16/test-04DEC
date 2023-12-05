from flask import Flask, render_template, request
import subprocess, os


app=Flask(__name__)


@app.route('/')
def home():
    return render_template("home.html")


@app.route("/reflect")
def reflect():
    inp = request.args.get("keyword")
    cmd = f"echo {inp}"
    try:
        output = subprocess.check_output(['/bin/sh', '-c', cmd], timeout=5)
        return render_template('reflect.html', data=output.decode('utf-8'))
    except subprocess.TimeoutExpired:
        return render_template('reflect.html', data='Timeout !')
    except subprocess.CalledProcessError:
        return render_template('reflect.html', data=f'an error occurred while executing the command. -> {cmd}')


if __name__=='__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
