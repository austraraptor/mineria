from flask import Flask, render_template, request, redirect, session, flash
import pymysql
import bcrypt
from datetime import date
app = Flask(__name__)
app.secret_key = '123465894561551561'

def get_db():
    return pymysql.connect(
        host="localhost",       # o IP
        user="root",
        password="123456dcc",
        db="mineria",         # tu base de datos real
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
@app.route('/')
def inicio():
    return redirect('/login')

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        u = request.form['username']
        pwd = request.form['password']
        db = get_db()
        with db.cursor() as cur:
            cur.execute("SELECT user_id, password_hash, role FROM users WHERE username=%s", (u,))
            row = cur.fetchone()
            if row and bcrypt.checkpw(pwd.encode(), row['password_hash'].encode()):
                session['user_id'] = row['user_id']
                session['role'] = row['role']
                session['password_clara'] = pwd
                # Redirección por rol
                if row['role'] == 'empleado':
                    return redirect('/dashboard')
                elif row['role'] == 'minero':
                    return redirect('/dashboard')
                elif row['role'] == 'asistencia':
                    return redirect('/asistencia/dashboard')
                elif row['role'] == 'administrador':
                    return redirect('/admin/dashboard')
                elif row['role'] == 'empresa':
                    return redirect('/empresa/dashboard')
            else:
                error = "Usuario o contraseña incorrectos"
    return render_template('login.html', error=error)


@app.route('/dashboard')
def dash():
    if 'role' not in session:
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        if session['role'] == 'empleado':
            cur.execute("SELECT COUNT(*) AS total FROM drivers WHERE status = 'activo'")
            total_conductores = cur.fetchone()['total']

            cur.execute("SELECT COUNT(*) AS total FROM vehicles WHERE status = 'disponible'")
            total_vehiculos = cur.fetchone()['total']

            cur.execute("SELECT COUNT(*) AS total FROM bookings WHERE status IN ('pendiente', 'reservado')")
            total_reservas = cur.fetchone()['total']

            cur.execute("""
                SELECT d.driver_id, u.username, d.license_type, d.status, v.plate, v.model
                FROM drivers d
                JOIN users u ON d.user_id = u.user_id
                LEFT JOIN bookings b ON b.driver_id = d.driver_id AND b.status IN ('pendiente', 'reservado')
                LEFT JOIN vehicles v ON v.vehicle_id = b.vehicle_id
                WHERE d.status = 'activo'
            """)
            drivers = cur.fetchall()

            cur.execute("SELECT username FROM users WHERE user_id = %s", (session['user_id'],))
            username = cur.fetchone()['username']

            return render_template('empleado_dashboard.html',
                                   drivers=drivers,
                                   total_conductores=total_conductores,
                                   total_vehiculos=total_vehiculos,
                                   total_reservas=total_reservas,
                                   username=username)

        elif session['role'] == 'minero':
            cur.execute("SELECT miner_id FROM miners WHERE user_id = %s", (session['user_id'],))
            miner = cur.fetchone()
            if miner:
                cur.execute("""
                    SELECT b.booking_id, v.plate, v.model, b.start_date, b.status
                    FROM bookings b
                    JOIN vehicles v ON b.vehicle_id = v.vehicle_id
                    WHERE b.miner_id = %s
                """, (miner['miner_id'],))
                bookings = cur.fetchall()
                return render_template('minero_dashboard.html', bookings=bookings)
            else:
                return "Minero no encontrado", 404

    return "Rol no reconocido", 403
@app.route('/empleado_dashboard')
@app.route('/empleado_dashboard')
def empleado_dashboard():
    if 'username' in session:
        return render_template('empleado_dashboard.html', username=session['username'])
    else:
        return render_template('empleado_dashboard.html')


@app.route('/empleado/inicio')
def empleado_inicio():
    if 'role' not in session or session['role'] != 'empleado':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        # Contar conductores activos
        cur.execute("SELECT COUNT(*) AS total FROM drivers WHERE status = 'activo'")
        total_conductores = cur.fetchone()['total']

        # Contar vehículos disponibles
        cur.execute("SELECT COUNT(*) AS total FROM vehicles WHERE status = 'disponible'")
        total_vehiculos = cur.fetchone()['total']

        # Contar reservas activas o pendientes
        cur.execute("SELECT COUNT(*) AS total FROM bookings WHERE status IN ('pendiente', 'reservado')")
        total_reservas = cur.fetchone()['total']

        # Obtener username del empleado autenticado
        cur.execute("SELECT username FROM users WHERE user_id = %s", (session['user_id'],))
        username = cur.fetchone()['username']

        # Obtener justificaciones por tardanza con username del minero
        cur.execute("""
            SELECT m.miner_id AS id_minero, u.username AS nombre_minero, t.message AS mensaje, t.fecha
            FROM tardiness_requests t
            JOIN miners m ON t.miner_id = m.miner_id
            JOIN users u ON m.user_id = u.user_id
            ORDER BY t.fecha DESC
        """)
        justificaciones = cur.fetchall()

    return render_template("empleado_inicio.html",
                           total_conductores=total_conductores,
                           total_vehiculos=total_vehiculos,
                           total_reservas=total_reservas,
                           username=username,
                           justificaciones=justificaciones)



@app.route('/perfil_empleado')
def perfil_empleado():
    if 'user_id' not in session or session['role'] != 'empleado':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        user_id = session['user_id']

        cur.execute("SELECT user_id, username, password_hash FROM users WHERE user_id = %s", (user_id,))
        user_data = cur.fetchone()

        cur.execute("SELECT d.driver_id, d.license_type FROM drivers d WHERE d.user_id = %s", (user_id,))
        licencia = cur.fetchone()
        driver_id = licencia['driver_id'] if licencia else None

        # 🚨 Leer usuario y clave del panel de asistencia vinculados
        usuario_panel, clave_panel = None, None
        if driver_id:
            cur.execute("""
                SELECT user_asistencia, clave_asistencia_plana
                FROM asistencia_vinculos
                WHERE driver_id = %s
            """, (driver_id,))
            vinculo = cur.fetchone()
            if vinculo:
                usuario_panel = vinculo['user_asistencia']
                clave_panel = vinculo['clave_asistencia_plana']

        # Vehículo asignado
        cur.execute("""
            SELECT v.model
            FROM bookings b
            JOIN vehicles v ON b.vehicle_id = v.vehicle_id
            JOIN drivers d ON b.driver_id = d.driver_id
            WHERE d.user_id = %s AND b.status IN ('pendiente', 'reservado')
            LIMIT 1
        """, (user_id,))
        vehiculo = cur.fetchone()

        # Incidentes
        cur.execute("""
            SELECT i.incident_type, i.description, i.date
            FROM incidents i
            JOIN bookings b ON i.booking_id = b.booking_id
            JOIN drivers d ON b.driver_id = d.driver_id
            WHERE d.user_id = %s
        """, (user_id,))
        incidentes = cur.fetchall()

        # Historial de viajes
        cur.execute("""
            SELECT t.notes
            FROM trip_history t
            JOIN bookings b ON t.booking_id = b.booking_id
            JOIN drivers d ON b.driver_id = d.driver_id
            WHERE d.user_id = %s
        """, (user_id,))
        historial = cur.fetchall()

    return render_template("empleado_perfil.html",
                           user=user_data,
                           licencia=licencia,
                           vehiculo=vehiculo,
                           incidentes=incidentes,
                           historial=historial,
                           password_clara=None,
                           usuario_panel=usuario_panel,
                           clave_panel=clave_panel)


@app.route('/empleado/asistencia', methods=['GET', 'POST'])
def empleado_asistencia():
    if 'role' not in session or session['role'] != 'empleado':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        if request.method == 'POST':
            asistencia_data = request.form
            for key, estado in asistencia_data.items():
                if key.startswith("attendance_"):
                    miner_id = int(key.split("_")[1])
                    cur.execute("""
                        INSERT INTO attendance (miner_id, fecha, estado, registrado_por)
                        VALUES (%s, CURDATE(), %s, 'contraseña')
                        ON DUPLICATE KEY UPDATE estado = VALUES(estado), registrado_por = 'contraseña'
                    """, (miner_id, estado))
            db.commit()
            return redirect('/empleado/asistencia')

        cur.execute("""
            SELECT m.miner_id, u.username, u.role, m.company,
                   a.estado
            FROM miners m
            JOIN users u ON m.user_id = u.user_id
            LEFT JOIN attendance a ON m.miner_id = a.miner_id AND a.fecha = CURDATE()
        """)
        mineros = cur.fetchall()

    return render_template("empleado_asistencia.html", mineros=mineros)

@app.route('/minero/dashboard')
def minero_dashboard():
    if 'user_id' in session and session.get('role') == 'minero':
        return render_template('minero_dashboard.html', username=session.get('user_id'))
    else:
        return render_template('minero_dashboard.html', username=session['username'])
  # redirige al login si no ha iniciado sesión


@app.route('/minero/inicio')
def minero_inicio():
    if 'role' not in session or session['role'] != 'minero':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        cur.execute("SELECT miner_id FROM miners WHERE user_id = %s", (session['user_id'],))
        miner = cur.fetchone()

        cur.execute("SELECT username FROM users WHERE user_id = %s", (session['user_id'],))
        username = cur.fetchone()['username']

        cur.execute("""
            SELECT COUNT(*) AS total
            FROM incidents i
            JOIN bookings b ON i.booking_id = b.booking_id
            WHERE b.miner_id = %s
        """, (miner['miner_id'],))
        total_incidentes = cur.fetchone()['total']

        horario = "7:00 - 16:00"

    return render_template("minero_inicio.html",
                           username=username,
                           miner_id=miner['miner_id'],
                           total_incidentes=total_incidentes,
                           horario=horario)

@app.route('/minero/perfil')
def minero_perfil():
    if 'role' not in session or session['role'] != 'minero':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        user_id = session['user_id']

        cur.execute("SELECT username, password_hash, role FROM users WHERE user_id = %s", (user_id,))
        user = cur.fetchone()

        cur.execute("SELECT miner_id, company FROM miners WHERE user_id = %s", (user_id,))
        miner = cur.fetchone()

        cur.execute("""
            SELECT v.model
            FROM bookings b
            JOIN vehicles v ON b.vehicle_id = v.vehicle_id
            WHERE b.miner_id = %s AND b.status IN ('pendiente', 'reservado')
            LIMIT 1
        """, (miner['miner_id'],))
        transporte = cur.fetchone()

    return render_template("minero_perfil.html",
                           username=user['username'],
                           user_id=user_id,
                           role=user['role'],
                           transporte=transporte['model'] if transporte else None,
                           company=miner['company'],
                           password_clara=session.get('password_clara'))

from datetime import date

from datetime import date

@app.route('/minero/reservas', methods=['GET', 'POST'])
def minero_reservas():
    if 'role' not in session or session['role'] != 'minero':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        # Obtener ID del minero
        cur.execute("SELECT miner_id FROM miners WHERE user_id = %s", (session['user_id'],))
        miner = cur.fetchone()

        # Verificar si tiene alguna asignación vigente
        cur.execute("""
            SELECT b.booking_id, v.vehicle_id, v.model, v.plate,
                   d.driver_id, u.username AS driver_name, d.license_type
            FROM bookings b
            JOIN vehicles v ON b.vehicle_id = v.vehicle_id
            JOIN drivers d ON b.driver_id = d.driver_id
            JOIN users u ON d.user_id = u.user_id
            WHERE b.miner_id = %s AND b.status IN ('pendiente', 'reservado')
            LIMIT 1
        """, (miner['miner_id'],))
        asignacion = cur.fetchone()

        # Obtener lista de mineros del mismo bus (opcional)
        otros_mineros = []
        if asignacion:
            cur.execute("""
                SELECT u.username, m.company
                FROM bookings b
                JOIN miners m ON b.miner_id = m.miner_id
                JOIN users u ON m.user_id = u.user_id
                WHERE b.vehicle_id = %s AND b.status IN ('pendiente', 'reservado')
            """, (asignacion['vehicle_id'],))
            otros_mineros = cur.fetchall()

        # ✅ Si el usuario envía solicitud de tardanza
        mensaje = None
        if request.method == 'POST':
            cur.execute("""
                SELECT * FROM service_requests
                WHERE miner_id = %s AND requested_date = CURDATE()
            """, (miner['miner_id'],))
            existente = cur.fetchone()
            if existente:
                mensaje = "Ya enviaste una solicitud hoy."
            else:
                cur.execute("""
                    INSERT INTO service_requests (miner_id, requested_date, status)
                    VALUES (%s, CURDATE(), 'pendiente')
                """, (miner['miner_id'],))
                db.commit()
                mensaje = "Solicitud de tardanza enviada correctamente."

    return render_template("minero_reservas.html", asignacion=asignacion, otros_mineros=otros_mineros, mensaje=mensaje)
@app.route('/minero/justificar_tardanza', methods=['POST'])
def justificar_tardanza():
    if 'role' not in session or session['role'] != 'minero':
        return redirect('/login')

    mensaje = request.form.get('mensaje', '').strip()
    db = get_db()

    with db.cursor() as cur:
        cur.execute("SELECT miner_id FROM miners WHERE user_id = %s", (session['user_id'],))
        miner = cur.fetchone()
        if miner and mensaje:
            cur.execute("""
                INSERT INTO tardiness_requests (miner_id, message)
                VALUES (%s, %s)
            """, (miner['miner_id'], mensaje))
            db.commit()

    return redirect('/minero/reservas')



@app.route('/asistencia/dashboard')
def asistencia_dashboard():
    if 'role' not in session or session['role'] != 'asistencia':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        cur.execute("SELECT username FROM users WHERE user_id = %s", (session['user_id'],))
        username = cur.fetchone()['username']

    return render_template("asistencia_dashboard.html", username=username)

@app.route('/asistencia/inicio')
def asistencia_inicio():
    if 'role' not in session or session['role'] != 'asistencia':
        return redirect('/login')
    
    db = get_db()
    with db.cursor() as cur:
        cur.execute("SELECT username FROM users WHERE user_id = %s", (session['user_id'],))
        username = cur.fetchone()['username']

    return render_template("asistencia_inicio.html", username=username)


@app.route('/asistencia/lista', methods=['GET', 'POST'])
def asistencia_lista():
    if 'role' not in session or session['role'] != 'asistencia':
        return redirect('/login')

    db = get_db()
    mensaje_error = None

    with db.cursor() as cur:
        # Verificar si ya se registraron asistencias hoy
        cur.execute("SELECT COUNT(*) AS total FROM attendance WHERE fecha = CURDATE()")
        total = cur.fetchone()['total']

        # Si no hay registros, marcamos a todos los mineros como ausentes
        if total == 0:
            cur.execute("SELECT miner_id FROM miners")
            todos_mineros = cur.fetchall()
            for minero in todos_mineros:
                cur.execute("""
                    INSERT INTO attendance (miner_id, fecha, estado, registrado_por)
                    VALUES (%s, CURDATE(), 'ausente', 'sistema')
                """, (minero['miner_id'],))
            db.commit()

        # REGISTRO POR LISTA (select por cada minero)
        if request.method == 'POST' and 'attendance_submit' in request.form:
            for key, estado in request.form.items():
                if key.startswith("attendance_"):
                    miner_id = int(key.split("_")[1])
                    cur.execute("""
                        UPDATE attendance
                        SET estado = %s, registrado_por = 'asistencia'
                        WHERE miner_id = %s AND fecha = CURDATE()
                    """, (estado, miner_id))
            db.commit()
            return redirect('/asistencia/lista')

        # REGISTRO MANUAL CON USUARIO Y CONTRASEÑA
        elif request.method == 'POST' and 'manual_submit' in request.form:
            username = request.form.get('username', '').strip()
            password = request.form.get('password', '').strip()

            cur.execute("""
                SELECT u.user_id, u.password_hash, m.miner_id
                FROM users u
                JOIN miners m ON u.user_id = m.user_id
                WHERE u.username = %s
            """, (username,))
            usuario = cur.fetchone()

            if usuario and bcrypt.checkpw(password.encode(), usuario['password_hash'].encode()):
                cur.execute("""
                    UPDATE attendance
                    SET estado = 'presente', registrado_por = 'asistencia'
                    WHERE miner_id = %s AND fecha = CURDATE()
                """, (usuario['miner_id'],))
                db.commit()
                return redirect('/asistencia/lista')
            else:
                mensaje_error = "Nombre de usuario o contraseña incorrectos."

        # Obtener nombre de quien registra (asistencia)
        cur.execute("SELECT username FROM users WHERE user_id = %s", (session['user_id'],))
        username = cur.fetchone()['username']

        # Obtener lista de mineros con su estado de asistencia de hoy
        cur.execute("""
            SELECT m.miner_id, u.username, u.role, m.company,
                   IFNULL(a.estado, 'ausente') AS estado
            FROM miners m
            JOIN users u ON m.user_id = u.user_id
            LEFT JOIN attendance a ON m.miner_id = a.miner_id AND a.fecha = CURDATE()
        """)
        mineros = cur.fetchall()

    return render_template("asistencia_lista.html", mineros=mineros, username=username, mensaje_error=mensaje_error)


@app.route('/admin/dashboard')
def admin_dashboard():
    if 'role' not in session or session['role'] != 'administrador':
        return redirect('/login')

    return render_template('admin_dashboard.html')

@app.route('/admin/inicio', methods=['GET', 'POST'])
def admin_inicio():
    if 'role' not in session or session['role'] != 'administrador':
        return redirect('/login')

    db = get_db()
    with db.cursor() as cur:
        # Si se hace clic en "Finalizar Registro"
        if request.method == 'POST':
            cur.execute("""
                UPDATE attendance
                SET estado = 'tardanza'
                WHERE fecha = CURDATE() AND estado IS NULL
            """)
            db.commit()

        # Obtener todas las asignaciones actuales con sus datos
        cur.execute("""
            SELECT 
                v.model AS vehiculo, v.plate AS placa,
                u.username AS conductor, 
                b.start_date AS horario,
                b.vehicle_id, b.driver_id
            FROM bookings b
            JOIN vehicles v ON b.vehicle_id = v.vehicle_id
            JOIN drivers d ON b.driver_id = d.driver_id
            JOIN users u ON d.user_id = u.user_id
            WHERE b.status IN ('pendiente', 'reservado')
            GROUP BY b.vehicle_id, b.driver_id
        """)
        asignaciones_raw = cur.fetchall()

        asignaciones = []
        for idx, row in enumerate(asignaciones_raw):
            # Obtener lista de mineros con asistencia para esa asignación
            cur.execute("""
                SELECT u.username, u.role, m.miner_id, m.company,
                       a.estado, a.registrado_por
                FROM bookings b
                JOIN miners m ON b.miner_id = m.miner_id
                JOIN users u ON m.user_id = u.user_id
                LEFT JOIN attendance a ON a.miner_id = m.miner_id AND a.fecha = CURDATE()
                WHERE b.vehicle_id = %s AND b.driver_id = %s
                AND b.status IN ('pendiente', 'reservado')
            """, (row['vehicle_id'], row['driver_id']))
            asistentes = cur.fetchall()

            asignaciones.append({
                'index': idx,
                'vehiculo': row['vehiculo'],
                'placa': row['placa'],
                'conductor': row['conductor'],
                'horario': row['horario'].strftime('%Y-%m-%d'),
                'asistencias': asistentes
            })

    return render_template("admin_inicio.html", asignaciones=asignaciones)

@app.route('/admin/registro', methods=['GET', 'POST'])
def admin_registro():
    if 'role' not in session or session['role'] != 'administrador':
        return redirect('/login')

    db = get_db()
    mensaje = ""

    if request.method == 'POST':
        tipo = request.form['tipo']
        dni = request.form['dni']
        hash_pw = bcrypt.hashpw(dni.encode(), bcrypt.gensalt()).decode()

        with db.cursor() as cur:
            # Insertar usuario principal
            cur.execute(
                "INSERT INTO users (username, password_hash, role) VALUES (%s, %s, %s)",
                (dni, hash_pw, tipo)
            )
            user_id = cur.lastrowid

            if tipo == 'minero':
                # Insertar en tabla miners
                cur.execute(
                    "INSERT INTO miners (user_id, company) VALUES (%s, %s)",
                    (user_id, request.form['empresa'])
                )
                miner_id = cur.lastrowid

                # Insertar datos extendidos
                cur.execute("""
                    INSERT INTO miners_extended (
                        miner_id, full_name, dni, edad, sexo, telefono, email, direccion,
                        area_trabajo, turno, fecha_inicio,
                        paradero_embarque, paradero_desembarque, horario_requerido,
                        regreso, contacto_emergencia, telefono_emergencia
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    miner_id,
                    request.form['full_name'], dni, request.form['edad'], request.form['sexo'],
                    request.form['telefono'], request.form['email'], request.form['direccion'],
                    request.form['area_trabajo'], request.form['turno'], request.form['fecha_inicio'],
                    request.form['paradero_embarque'], request.form['paradero_desembarque'],
                    request.form['horario_transporte'], request.form.get('requiere_regreso') == 'on',
                    request.form['contacto_emergencia_nombre'], request.form['contacto_emergencia_telefono']
                ))

            elif tipo == 'empleado':
                # Insertar en tabla drivers
                cur.execute(
                    "INSERT INTO drivers (user_id, license_type, sctr_cert) VALUES (%s, %s, %s)",
                    (user_id, request.form['tipo_licencia'], request.form.get('sctr_cert') == 'on')
                )
                driver_id = cur.lastrowid

                # Insertar datos extendidos
                cur.execute("""
                    INSERT INTO drivers_extended (
                        driver_id, dni, edad, sexo, telefono, email, direccion,
                        licencia_tipo, licencia_numero, licencia_vencimiento,
                        sctr, empresa_transporte, turno, fecha_inicio,
                        contacto_emergencia, telefono_emergencia
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    driver_id,
                    dni, request.form['edad'], request.form['sexo'], request.form['telefono'],
                    request.form['email'], request.form['direccion'], request.form['tipo_licencia'],
                    request.form['numero_licencia'], request.form['vencimiento_licencia'],
                    request.form.get('sctr_cert') == 'on', request.form['empresa_transporte'],
                    request.form['turno'], request.form['fecha_inicio'],
                    request.form['contacto_emergencia_nombre'], request.form['contacto_emergencia_telefono']
                ))

                # Crear usuario adicional para asistencia
                username_asistencia = f"{dni}_asis"
                hash_pw_asistencia = bcrypt.hashpw(dni.encode(), bcrypt.gensalt()).decode()

                cur.execute(
                    "INSERT INTO users (username, password_hash, role) VALUES (%s, %s, %s)",
                    (username_asistencia, hash_pw_asistencia, 'asistencia')
                )

                # Guardar vínculo entre conductor y cuenta de asistencia
                cur.execute("""
                    INSERT INTO asistencia_vinculos (driver_id, user_asistencia, clave_asistencia_plana)
                    VALUES (%s, %s, %s)
                """, (driver_id, username_asistencia, dni))

            db.commit()
            mensaje = "Usuario registrado correctamente."

    return render_template("admin_registro.html", mensaje=mensaje)


@app.route('/admin/asignar', methods=['GET', 'POST'])
def admin_asignar():
    if 'role' not in session or session['role'] != 'administrador':
        return redirect('/login')

    db = get_db()
    mensaje_exito = None
    turno_actual = request.form.get('turno', 'mañana')  # Turno por defecto

    with db.cursor() as cur:
        if request.method == 'POST':
            # Registro de nuevo vehículo
            if 'plate' in request.form and 'vin_number' in request.form:
                try:
                    cur.execute("""
                        INSERT INTO transport_units (
                            plate, vin_number, model, brand, manufacture_year,
                            seat_capacity, fuel_type, company_name, company_ruc,
                            assigned_driver_id, license_number, license_category
                        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """, (
                        request.form['plate'],
                        request.form['vin_number'],
                        request.form['model'],
                        request.form['brand'],
                        request.form['manufacture_year'],
                        request.form['seat_capacity'],
                        request.form['fuel_type'],
                        request.form['company_name'],
                        request.form['company_ruc'],
                        request.form['assigned_driver_id'],
                        request.form['license_number'],
                        request.form['license_category']
                    ))
                    db.commit()
                    mensaje_exito = "Vehículo registrado correctamente."
                except Exception as e:
                    db.rollback()
                    if 'Duplicate entry' in str(e) and 'plate' in str(e):
                        mensaje_exito = "Error: Ya existe un vehículo registrado con esa placa."
                    else:
                        mensaje_exito = f"Error al registrar vehículo: {str(e)}"

            # Asignación de mineros
            elif 'driver_id' in request.form and 'vehicle_id' in request.form:
                driver_id = request.form['driver_id']
                vehicle_id = request.form['vehicle_id']
                miner_ids = request.form.getlist('miner_ids')

                if len(miner_ids) > 25:
                    mensaje_exito = "Error: Solo se pueden asignar hasta 25 mineros por vehículo."
                else:
                    try:
                        for miner_id in miner_ids:
                            cur.execute("""
                                INSERT INTO bookings (miner_id, vehicle_id, driver_id, start_date, status)
                                VALUES (%s, %s, %s, CURDATE(), 'reservado')
                            """, (miner_id, vehicle_id, driver_id))
                        db.commit()
                        mensaje_exito = "Se asignaron los mineros correctamente al vehículo."
                    except Exception as e:
                        db.rollback()
                        mensaje_exito = f"Error al asignar mineros: {str(e)}"

        # Cargar conductores
        cur.execute("""
            SELECT d.driver_id, u.username, d.license_type
            FROM drivers d
            JOIN users u ON d.user_id = u.user_id
            WHERE u.role = 'empleado'
        """)
        conductores = cur.fetchall()

        # Vehículos disponibles
        cur.execute("SELECT vehicle_id, plate, model FROM vehicles WHERE status = 'disponible'")
        vehiculos = cur.fetchall()

        # Mineros por turno
        cur.execute("""
            SELECT m.miner_id, u.username, m.company
            FROM miners m
            JOIN users u ON m.user_id = u.user_id
            JOIN miners_extended me ON m.miner_id = me.miner_id
            WHERE me.turno = %s
        """, (turno_actual,))
        mineros = cur.fetchall()

    return render_template("admin_asignar.html",
                           conductores=conductores,
                           vehiculos=vehiculos,
                           mineros=mineros,
                           mensaje_exito=mensaje_exito,
                           turno=turno_actual)

@app.route('/empresa/dashboard')
def empresa_dashboard():
    if 'role' not in session or session['role'] != 'empresa':
        return redirect('/login')

    return render_template("empresa_dashboard.html")

@app.route('/empresa/inicio')
def empresa_inicio():
    if 'role' not in session or session['role'] != 'empresa':
        return redirect('/login')

    db = get_db()
    user_id = session['user_id']

    with db.cursor() as cur:
        # Obtener datos de la empresa logueada
        cur.execute("SELECT nombre FROM companies WHERE user_id = %s", (user_id,))
        empresa = cur.fetchone()

        if not empresa:
            return "Empresa no encontrada", 404

        nombre_empresa = empresa['nombre']

        # Obtener mineros asociados
        cur.execute("""
            SELECT u.username, m.company, me.turno, me.horario_requerido,
                   b.start_date, b.status, a.estado, a.fecha,
                   tr.message AS justificacion
            FROM miners m
            JOIN users u ON m.user_id = u.user_id
            LEFT JOIN miners_extended me ON m.miner_id = me.miner_id
            LEFT JOIN bookings b ON m.miner_id = b.miner_id
            LEFT JOIN attendance a ON m.miner_id = a.miner_id
            LEFT JOIN tardiness_requests tr ON m.miner_id = tr.miner_id
            WHERE m.company = %s
            ORDER BY a.fecha DESC
        """, (nombre_empresa,))
        registros = cur.fetchall()

    return render_template('empresa_inicio.html',
                           empresa=nombre_empresa,
                           registros=registros)

@app.route('/empresa/notificaciones')
def empresa_notificaciones():
    if 'role' not in session or session['role'] != 'empresa':
        return redirect('/login')

    db = get_db()
    user_id = session['user_id']

    with db.cursor() as cur:
        cur.execute("SELECT nombre FROM companies WHERE user_id = %s", (user_id,))
        empresa = cur.fetchone()
        if not empresa:
            return "Empresa no encontrada", 404

        nombre_empresa = empresa['nombre']

        # Buscar vencimientos de licencias y revisiones
        cur.execute("""
            SELECT de.licencia_vencimiento, u.username AS conductor
            FROM drivers_extended de
            JOIN drivers d ON de.driver_id = d.driver_id
            JOIN users u ON d.user_id = u.user_id
            WHERE de.empresa_transporte = %s
              AND de.licencia_vencimiento < CURDATE() + INTERVAL 30 DAY
        """, (nombre_empresa,))
        vencimientos = cur.fetchall()

        # Retrasos o cancelaciones
        cur.execute("""
            SELECT b.start_date, b.status, u.username
            FROM bookings b
            JOIN miners m ON b.miner_id = m.miner_id
            JOIN users u ON m.user_id = u.user_id
            WHERE m.company = %s
              AND b.status IN ('cancelado', 'pendiente')
        """, (nombre_empresa,))
        retrasos = cur.fetchall()

    return render_template('empresa_notificaciones.html',
                           empresa=nombre_empresa,
                           vencimientos=vencimientos,
                           retrasos=retrasos)



@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')
if __name__ == "__main__":
    app.run(debug=True)