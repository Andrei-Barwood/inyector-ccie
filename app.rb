require 'sinatra'
require 'net/ssh'
require 'sqlite3'

set :bind, '0.0.0.0'
set :port, 4567

DB = SQLite3::Database.new("data/macros.db")
DB.results_as_hash = true
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS macros (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    commands TEXT
  );
SQL

get '/' do
  @macros = DB.execute("SELECT * FROM macros ORDER BY name ASC")
  erb :index
end

post '/guardar' do
  DB.execute("INSERT INTO macros (name, commands) VALUES (?, ?)", [params[:name], params[:commands]])
  redirect '/'
end

post '/inyectar' do
  @ip = params[:ip]
  user = params[:user]
  pass = params[:password]
  
  macro_text = params[:macro_id] && !params[:macro_id].empty? ? 
               DB.execute("SELECT commands FROM macros WHERE id = ?", params[:macro_id]).first['commands'] : 
               params[:macro_custom]

  commands = macro_text.split(/\r?\n/).reject(&:empty?)
  @output = ""

  begin
    Net::SSH.start(@ip, user, password: pass, verify_host_key: :never) do |ssh|
      ssh.open_channel do |channel|
        channel.request_pty do |ch, success|
          abort "No PTY" unless success
          ch.on_data { |_, data| @output << data }
          commands.each do |cmd|
            ch.send_data "#{cmd}\n"
            sleep 0.3
          end
          ch.send_data "exit\n"
        end
      end
      ssh.loop
    end
  rescue StandardError => e
    @output = "Error: #{e.message}"
  end

  erb :result
end

__END__

@@ layout
<!DOCTYPE html>
<html>
<head>
  <title>CCIE Macro Injector</title>
  <style>
    body { background: #1e1e1e; color: #d4d4d4; font-family: monospace; padding: 20px; }
    input, textarea, select, button { background: #2d2d2d; color: #fff; border: 1px solid #444; padding: 10px; width: 100%; box-sizing: border-box; margin-bottom: 10px; font-family: monospace; }
    textarea { height: 150px; }
    button { background: #007acc; cursor: pointer; font-weight: bold; border: none; }
    button:hover { background: #0098ff; }
    .grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
    .card { border: 1px solid #333; padding: 15px; margin-bottom: 20px; background: #252526; }
    .terminal { background: #000; color: #0f0; padding: 15px; overflow-y: auto; height: 300px; }
  </style>
</head>
<body><%= yield %></body>
</html>

@@ index
<h2>⚡ CCIE Macro Injector</h2>

<div class="card">
  <h3>1. Guardar Nueva Macro en DB</h3>
  <form action="/guardar" method="POST">
    <input type="text" name="name" placeholder="Nombre (ej: OSPF Area 0, Config IPv6)" required>
    <textarea name="commands" placeholder="Pega tu macro aquí..." required></textarea>
    <button type="submit" style="background: #28a745;">GUARDAR EN BASE DE DATOS</button>
  </form>
</div>

<div class="card">
  <h3>2. Inyectar a la Red</h3>
  <form action="/inyectar" method="POST">
    <div class="grid">
      <input type="text" name="ip" placeholder="IP del Equipo" required>
      <input type="text" name="user" placeholder="Usuario" required>
      <input type="password" name="password" placeholder="Contraseña" required>
    </div>
    
    <select name="macro_id">
      <option value="">-- Selecciona una macro guardada o usa el cuadro de texto --</option>
      <% @macros.each do |m| %>
        <option value="<%= m['id'] %>"><%= m['name'] %></option>
      <% end %>
    </select>
    
    <textarea name="macro_custom" placeholder="... o pega una macro temporal aquí"></textarea>
    <button type="submit">INYECTAR</button>
  </form>
</div>

@@ result
<h2>Resultado de inyección en <%= @ip %></h2>
<div class="terminal"><pre><%= @output %></pre></div>
<br><form action="/"><button type="submit">Volver a la consola</button></form>
