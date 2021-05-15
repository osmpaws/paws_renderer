from flask import Flask, render_template, request,send_file
import os, time, socket


app = Flask(__name__)
port = 5001

def getaddrconn():
    try:
        hostname = socket.gethostname()
    except:
        hostname = ""
    return hostname

@app.route('/')
def index():
    hostname = getaddrconn()
    files = [ f for f in os.listdir('.') if os.path.isfile(f) and (str(f).endswith(".zip") or str(f).endswith(".map") or str(f).endswith(".poi"))]
    data = []
    for f in files:
        data.append({ 'filename': f, 'tstamp': time.ctime(os.path.getmtime(f))})
    return render_template('index.html', data=data, hostname=hostname, port=port)
    
@app.route('/locus-action/<archive>')
def locusaction(archive):
    global port
    name = archive
    if archive.endswith('.zip'):
        name = archive[:-4]
    size = os.path.getsize(archive)
    return render_template('locus-action.xml', size=size, name=name, port=port)
    
@app.route('/<archive>/locus-action.xml')
def locusactionxml(archive):
    global port
    hostname = getaddrconn()
    name = archive
    size = os.path.getsize(archive)
    if archive.endswith('.zip'):
        name = archive[:-4]
        return render_template('locus-action.xml', size=size, name=name, hostname=hostname, port=port)
    elif archive.endswith('.map') or archive.endswith('.poi'):
        name = archive[:-4]
        return render_template('locus-action-map.xml', size=size, name=name, hostname=hostname, port=port)
    else:
        archive = archive + ".zip"
    
@app.route('/download/<archive>')
def download(archive = None):
    if archive.endswith('.zip') or archive.endswith('.map') or archive.endswith('.poi'):
        return send_file(archive, as_attachment=True, cache_timeout=0)

if __name__ == '__main__':
    app.run(debug=False, threaded=True, host='0.0.0.0', port=port)
