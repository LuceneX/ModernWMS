import os,sqlite3,subprocess,tempfile
from pathlib import Path
repo=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as d:
 root=Path(d); app=root/'app';app.mkdir();bin=root/'bin';bin.mkdir()
 for name in ['seed-sqlite.sql','ensure-sqlite-schema.sh']:(app/name).write_bytes((repo/'backend/ModernWMS/Database'/name).read_bytes())
 start=app/'start.sh';start.write_text((repo/'docker/start-backend.sh').read_text().replace('/app',str(app)))
 stub=bin/'dotnet';stub.write_text('#!/bin/sh\nprintf "%s\\n" "$ConnectionStrings__SqlLiteConn"\n');stub.chmod(0o755)
 env={**os.environ,'PATH':str(bin)+':'+os.environ['PATH']}
 def run(db,success=True):
  r=subprocess.run(['bash',str(start)],env={**env,'WMS_DB_PATH':str(db)},capture_output=True,text=True)
  assert (r.returncode==0)==success,(r.returncode,r.stdout,r.stderr)
  return r
 fresh=root/'fresh.db';run(fresh)
 c=sqlite3.connect(fresh);assert c.execute('select count(*) from rolemenu').fetchone()[0]>=19
 c.execute('create table deployment_probe(value text)');c.execute("insert into deployment_probe values('keep me')");c.commit();c.close();run(fresh)
 c=sqlite3.connect(fresh);assert c.execute('select value from deployment_probe').fetchone()[0]=='keep me';c.close();print('PASS fresh boot, schema reconciliation, restart and preserved records')
 partial=root/'partial.db';c=sqlite3.connect(partial);c.execute('create table action_log(id integer primary key, vue_path text,user_name text,action_content text,action_time text,tenant_id integer)');c.commit();c.close();run(partial);print('PASS recovery from empty partially initialized database')
 populated=root/'populated.db';c=sqlite3.connect(populated);c.execute('create table customer(id integer primary key)');c.execute('insert into customer values(42)');c.commit();c.close();run(populated,False);c=sqlite3.connect(populated);assert c.execute('select id from customer').fetchone()[0]==42;c.close();print('PASS refuses to seed over populated incompatible database')
 corrupt=root/'corrupt.db';corrupt.write_bytes(b'not a database');run(corrupt,False);print('PASS refuses corrupt database')
