from flask import Flask, send_file
import subprocess

app = Flask(__name__)
cnt = 0


@app.route('/')
def hello_world():
    global cnt
    print("running cap")
    cnt += 1
    subprocess.run(
        ["raspistill", "-n", "-3d", "sbs", "-w", "2560", "-h", "720", "-cs", "1", "-md", "6", "-t", "309", "-o", "/media/DCIM/d.jpg"],
        capture_output=True)
    return send_file("/media/DCIM/d.jpg", mimetype='image/jpeg')


app.run('0.0.0.0', 3250)
