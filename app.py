# distinguish between GET & POST requests


from flask import Flask, render_template, request
import subprocess


app=Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        inp = request.form.get("keyword")
        cmd = f"echo {inp}"
        try:
            output = subprocess.check_output(['/bin/sh', '-c', cmd], timeout=5)
            return render_template('moo.html', data=output.decode('utf-8'))
        except subprocess.TimeoutExpired:
            return render_template('moo.html', data='Timeout !')
        except subprocess.CalledProcessError:
            return render_template('moo.html', data=f'an error occurred while executing the command. -> {cmd}')
    
    return render_template("home.html")


if __name__=='__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
