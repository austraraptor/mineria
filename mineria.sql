-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-07-2025 a las 05:48:38
-- Versión del servidor: 10.4.32-MariaDB-log
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `mineria`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia_vinculos`
--

CREATE TABLE `asistencia_vinculos` (
  `id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `user_asistencia` varchar(50) NOT NULL,
  `clave_asistencia_plana` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `asistencia_vinculos`
--

INSERT INTO `asistencia_vinculos` (`id`, `driver_id`, `user_asistencia`, `clave_asistencia_plana`) VALUES
(1, 3, '73021458_asis', '73021458'),
(2, 4, '78965412_asis', '78965412'),
(3, 5, '71112222_asis', '71112222');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `attendance`
--

CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL,
  `miner_id` int(11) NOT NULL,
  `fecha` date DEFAULT curdate(),
  `estado` enum('presente','ausente','tardanza') DEFAULT 'ausente',
  `registrado_por` enum('facial','contraseña','asistencia') DEFAULT 'contraseña'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `attendance`
--

INSERT INTO `attendance` (`attendance_id`, `miner_id`, `fecha`, `estado`, `registrado_por`) VALUES
(4, 1, '2025-07-15', 'presente', 'asistencia'),
(5, 1, '2025-07-16', 'ausente', ''),
(6, 2, '2025-07-16', 'ausente', ''),
(7, 9, '2025-07-16', 'ausente', ''),
(8, 1, '2025-07-17', 'presente', 'asistencia'),
(9, 2, '2025-07-17', 'ausente', ''),
(10, 9, '2025-07-17', 'ausente', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `miner_id` int(11) NOT NULL,
  `vehicle_id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('pendiente','reservado','cancelado') DEFAULT 'pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bookings`
--

INSERT INTO `bookings` (`booking_id`, `miner_id`, `vehicle_id`, `driver_id`, `start_date`, `end_date`, `status`) VALUES
(1, 1, 1, 1, '2025-06-20', '2025-06-22', 'reservado'),
(2, 2, 2, 2, '2025-06-25', '2025-06-28', 'reservado'),
(3, 9, 1, 1, '2025-07-16', NULL, 'reservado'),
(4, 9, 1, 4, '2025-07-17', NULL, 'reservado'),
(5, 11, 1, 4, '2025-07-17', NULL, 'reservado'),
(6, 11, 1, 3, '2025-07-17', NULL, 'reservado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `companies`
--

CREATE TABLE `companies` (
  `company_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `ruc` varchar(20) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `companies`
--

INSERT INTO `companies` (`company_id`, `nombre`, `ruc`, `user_id`) VALUES
(1, 'Compañía Minera Santa María S.A.', '12345678901', 19),
(2, 'Tintaya SAC', '20456789012', 20),
(3, 'Costa rica minera', '20567890123', 21);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `drivers`
--

CREATE TABLE `drivers` (
  `driver_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `license_type` varchar(10) DEFAULT NULL,
  `sctr_cert` tinyint(1) DEFAULT 0,
  `status` enum('activo','inactivo') DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `drivers`
--

INSERT INTO `drivers` (`driver_id`, `user_id`, `license_type`, `sctr_cert`, `status`) VALUES
(1, 1, 'A-IIIa', 1, 'activo'),
(2, 2, 'A-IIb', 1, 'activo'),
(3, 17, 'C-IIIq', 1, 'activo'),
(4, 23, 'C-IIIq', 1, 'activo'),
(5, 25, 'A-IIIq', 1, 'activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `drivers_extended`
--

CREATE TABLE `drivers_extended` (
  `id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `dni` varchar(15) DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `sexo` enum('masculino','femenino','otro') DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `licencia_tipo` varchar(20) DEFAULT NULL,
  `licencia_numero` varchar(20) DEFAULT NULL,
  `licencia_vencimiento` date DEFAULT NULL,
  `sctr` tinyint(1) DEFAULT NULL,
  `empresa_transporte` varchar(100) DEFAULT NULL,
  `turno` enum('mañana','tarde','noche') DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `contacto_emergencia` varchar(100) DEFAULT NULL,
  `telefono_emergencia` varchar(20) DEFAULT NULL,
  `foto_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `drivers_extended`
--

INSERT INTO `drivers_extended` (`id`, `driver_id`, `dni`, `edad`, `sexo`, `telefono`, `email`, `direccion`, `licencia_tipo`, `licencia_numero`, `licencia_vencimiento`, `sctr`, `empresa_transporte`, `turno`, `fecha_inicio`, `contacto_emergencia`, `telefono_emergencia`, `foto_path`) VALUES
(1, 3, '73021458', 18, 'masculino', '978456321', 'juan3@gmail.com', 'Enrique segoniavo', 'C-IIIq', 'B12345678', '2029-12-12', 1, 'transporte minero', 'mañana', '2026-02-12', 'malcol segurata', '978412587', NULL),
(2, 4, '78965412', 26, 'masculino', '912345674', 'edy@gmail.com', 'Enrique segoniavo', 'C-IIIq', 'B12345678', '2030-10-20', 1, 'Compañía Minera Santa María S.A.', 'tarde', '2025-11-20', 'malcol segurata', '978412588', NULL),
(3, 5, '71112222', 29, 'masculino', '941025478', 'algin@apptransporte.com', 'Enrique segoniavo', 'A-IIIq', 'B12345677', '2030-02-23', 1, 'Compañía Minera Santa María S.A.', 'tarde', '2025-11-20', 'malcol segurata', '978412580', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `incidents`
--

CREATE TABLE `incidents` (
  `incident_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `incident_type` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `incidents`
--

INSERT INTO `incidents` (`incident_id`, `booking_id`, `incident_type`, `description`, `date`) VALUES
(1, 1, 'averia vehicular', 'El vehículo tuvo una falla en el motor en la ruta a mina.', '2025-06-16 21:26:01'),
(2, 2, 'invalidez chofer', 'El conductor se reportó con síntomas de fiebre y fue reemplazado.', '2025-06-16 21:26:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `miners`
--

CREATE TABLE `miners` (
  `miner_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `company` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `miners`
--

INSERT INTO `miners` (`miner_id`, `user_id`, `company`) VALUES
(1, 3, 'Compañía Minera Santa María S.A.'),
(2, 4, 'Tintaya SAC'),
(9, 16, 'Costa rica minera'),
(10, 22, 'Costa rica minera'),
(11, 28, 'Costa rica minera'),
(12, 29, 'Costa rica minera');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `miners_extended`
--

CREATE TABLE `miners_extended` (
  `id` int(11) NOT NULL,
  `miner_id` int(11) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `dni` varchar(15) DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `sexo` enum('masculino','femenino','otro') DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `area_trabajo` varchar(100) DEFAULT NULL,
  `turno` enum('mañana','tarde','noche') DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `paradero_embarque` varchar(100) DEFAULT NULL,
  `paradero_desembarque` varchar(100) DEFAULT NULL,
  `horario_requerido` time DEFAULT NULL,
  `regreso` tinyint(1) DEFAULT NULL,
  `contacto_emergencia` varchar(100) DEFAULT NULL,
  `telefono_emergencia` varchar(20) DEFAULT NULL,
  `foto_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `miners_extended`
--

INSERT INTO `miners_extended` (`id`, `miner_id`, `full_name`, `dni`, `edad`, `sexo`, `telefono`, `email`, `direccion`, `area_trabajo`, `turno`, `fecha_inicio`, `paradero_embarque`, `paradero_desembarque`, `horario_requerido`, `regreso`, `contacto_emergencia`, `telefono_emergencia`, `foto_path`) VALUES
(1, 9, 'NAIN zuñiga', '75869874', 28, 'masculino', '912345674', 'juan3@gmail.com', 'Enrique segoniavo', 'minero', 'mañana', '2025-08-20', 'terminal terrestre', 'mina de azangaro', '07:00:00', 1, 'salamanca', '978412589', NULL),
(2, 10, 'Mario vargas', '73408028', 30, 'masculino', '901236547', 'juan@gmail.com', 'Enrique segoniavo', 'minero', 'tarde', '2025-10-30', 'terminal terrestre', 'mina de azangaro', '07:00:00', 1, 'salamanca', '978412587', NULL),
(3, 11, 'Juan Carlos', '79112547', 28, 'masculino', '941025478', 'juan23@gmail.com', 'Enrique segoniavo 112', 'minero', 'mañana', '2025-12-20', 'terminal terrestre', 'mina de azangaro', '07:00:00', 1, 'malcol segurata', '978412588', NULL),
(4, 12, 'carlos beltran', '78965432', 30, 'masculino', '941025478', 'edy@gmail.com', 'Enrique segoniavo', 'minero', 'mañana', '0000-00-00', 'terminal terrestre', 'mina de azangaro', '07:00:00', 1, 'Mario', '978412588', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `service_requests`
--

CREATE TABLE `service_requests` (
  `request_id` int(11) NOT NULL,
  `miner_id` int(11) NOT NULL,
  `requested_date` date DEFAULT NULL,
  `status` enum('pendiente','aprobado','rechazado') DEFAULT 'pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `service_requests`
--

INSERT INTO `service_requests` (`request_id`, `miner_id`, `requested_date`, `status`) VALUES
(1, 1, '2025-06-14', 'pendiente'),
(2, 1, '2025-06-10', 'aprobado'),
(3, 1, '2025-06-08', 'rechazado'),
(4, 1, '2025-07-15', 'pendiente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tardiness_requests`
--

CREATE TABLE `tardiness_requests` (
  `id` int(11) NOT NULL,
  `miner_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tardiness_requests`
--

INSERT INTO `tardiness_requests` (`id`, `miner_id`, `message`, `fecha`) VALUES
(1, 1, 'tube problemas medicos', '2025-07-15 14:03:15'),
(2, 2, 'fallecimiento de familiar', '2025-07-15 14:08:12'),
(3, 1, 'licencia medica', '2025-07-17 14:15:05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transport_units`
--

CREATE TABLE `transport_units` (
  `transport_id` int(11) NOT NULL,
  `plate` varchar(10) NOT NULL,
  `vin_number` varchar(50) NOT NULL,
  `model` varchar(50) DEFAULT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `manufacture_year` year(4) DEFAULT NULL,
  `seat_capacity` int(11) DEFAULT NULL CHECK (`seat_capacity` between 1 and 100),
  `fuel_type` enum('gasolina','diesel','gnv','glp','eléctrico') NOT NULL,
  `company_name` varchar(100) DEFAULT NULL,
  `company_ruc` varchar(20) DEFAULT NULL,
  `assigned_driver_id` int(11) DEFAULT NULL,
  `license_number` varchar(20) DEFAULT NULL,
  `license_category` varchar(10) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `transport_units`
--

INSERT INTO `transport_units` (`transport_id`, `plate`, `vin_number`, `model`, `brand`, `manufacture_year`, `seat_capacity`, `fuel_type`, `company_name`, `company_ruc`, `assigned_driver_id`, `license_number`, `license_category`, `created_at`, `updated_at`) VALUES
(1, 'AQW-987', '9BWZZZ377VT004251', 'Gran Viale', 'Mercedes-Benz', '2019', 25, 'diesel', 'samsong bolivia', '20605478512', 1, 'B47625914', 'A-IIIb', '2025-07-16 11:16:52', '2025-07-16 11:16:52'),
(4, 'qws-147', '9svdZZZ377VT00999', 'Forman', 'Langorgini', '2025', 25, 'diesel', 'samsong bolivia', '20605478513', 3, 'H4762591B', 'A-IIIb', '2025-07-17 18:13:55', '2025-07-17 18:13:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `trip_history`
--

CREATE TABLE `trip_history` (
  `trip_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `completed_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `trip_history`
--

INSERT INTO `trip_history` (`trip_id`, `booking_id`, `completed_date`, `notes`) VALUES
(1, 2, '2025-06-12', 'recorrido completado'),
(2, 2, '2025-06-12', 'Se recomendó cambio de filtro de aire.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(60) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('empleado','minero','asistencia','administrador','empresa') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`user_id`, `username`, `password_hash`, `role`) VALUES
(1, 'jlopez', '$2a$12$jUNU33i025oAedqMK3jIkeDDAAKwZPPbhgGlBp4iVXEe.QU91/FTq', 'empleado'),
(2, 'mvaldez', '$2b$12$R2SMMACXnZVtbiEv4hHH4eFLpTxv6prjBOCEJv3hTe7c60Znl9pxu', 'empleado'),
(3, 'mina_santa', '$2a$12$KtGbGsRchQqU9Wt.slRKxOqn6NXRB5khyaqTT/0ey1q42MOQ9tB/.', 'minero'),
(4, 'tintaya_sac', '$2a$12$AxSRMlQqwm09zxSgqOQbLehbiid5Y9OZqUOP4gyQEImeURVU5yYEG', 'minero'),
(5, 'asistente1', '$2a$12$Q79DGZ3UWKksVEke6g7q8e/JChz0MO9lBdKwHk979wIphEIYl1kNS', 'asistencia'),
(6, 'admin1', '$2a$12$zf.ne2MwzDUhty0tMd9Jb.0Ao7TPdrCOTaOdU1vkcTaNZ/TSOj9Wy', 'administrador'),
(16, '75869874', '$2b$12$tZIU4/FTPpck/GO2CpxFgOdXHirqujxOOaKXNcciBnUwbGxh98Px6', 'minero'),
(17, '73021458', '$2b$12$6gU1bw54Js9lPVLppHGtc.h93/BUe3dJG3Jod92PBk31ZVQV2D2KK', 'empleado'),
(18, '73021458_asis', '$2b$12$fdKSjiJU1e6NpLAuMpUpYedI7KQYYqPSKn8DJHVKa80n50YoK/WeS', 'asistencia'),
(19, 'empresa_santa_maria', '$2a$12$/5HEfNyebaa80YLYwvyliO9yPXiCFWqD3ht0cHTTEQnkvArq6aieO', 'empresa'),
(20, 'empresa_tintaya', '$2a$12$qnlGeTckqsb9DIU0liPj4.eAvRqOeEdP6UYBu5saeDKZz9BGK/FI.', 'empresa'),
(21, 'empresa_costarica', '$2a$12$Ga2IkZ9iTKC5skye/mfN3.mRzDjSwQXxph6UFsRMA5mt/18xcM2cO', 'empresa'),
(22, '73408028', '$2b$12$m3ZadFoGOEMNftxZhVh58.OKG66IsOmCyz4d25YXelikgN4XjnNAq', 'minero'),
(23, '78965412', '$2b$12$Tv05WUWN9QmcWdziVM8eDuGxl7M5DhrOwmMNlwSSjDLBSJYMO/VNm', 'empleado'),
(24, '78965412_asis', '$2b$12$uKv3dSz11cBAw93zRud9Quo.wqf2KsUKIhhOsTUq0TUivEJfF9Vsa', 'asistencia'),
(25, '71112222', '$2b$12$jYeeNDnzWAljtwIHKjfeTuOofeSantF46UxMFAGsh4FLgRGYgVB5m', 'empleado'),
(26, '71112222_asis', '$2b$12$2Wc9zelWSfI4/XToZ4zey.h4vKcAe1Xp1JVfuk6.EFqZKUi/8flCG', 'asistencia'),
(28, '79112547', '$2b$12$t2kiOQxb3RYH.0uCyDKkk.RdPoTGsDxikNfJ6xNKDSJF3QuRm3VQG', 'minero'),
(29, '78965432', '$2b$12$Bo5IyXpVcmRiRhaTr2ov6uGiLU7Ch.SC5MD6BtqQSMiaTDXk4v0lK', 'minero');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicle_id` int(11) NOT NULL,
  `plate` varchar(10) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `status` enum('disponible','reservado','mantenimiento') DEFAULT 'disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vehicles`
--

INSERT INTO `vehicles` (`vehicle_id`, `plate`, `model`, `status`) VALUES
(1, 'ABC-123', 'Toyota Hilux 4x4', 'disponible'),
(2, 'XYZ-789', 'Mitsubishi L200', 'disponible'),
(3, 'LMN-456', 'Volkswagen Crafter Bus', 'mantenimiento');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `asistencia_vinculos`
--
ALTER TABLE `asistencia_vinculos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_id` (`driver_id`);

--
-- Indices de la tabla `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD KEY `miner_id` (`miner_id`);

--
-- Indices de la tabla `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `miner_id` (`miner_id`),
  ADD KEY `vehicle_id` (`vehicle_id`),
  ADD KEY `driver_id` (`driver_id`);

--
-- Indices de la tabla `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`company_id`),
  ADD UNIQUE KEY `ruc` (`ruc`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`driver_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `drivers_extended`
--
ALTER TABLE `drivers_extended`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_id` (`driver_id`);

--
-- Indices de la tabla `incidents`
--
ALTER TABLE `incidents`
  ADD PRIMARY KEY (`incident_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indices de la tabla `miners`
--
ALTER TABLE `miners`
  ADD PRIMARY KEY (`miner_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `miners_extended`
--
ALTER TABLE `miners_extended`
  ADD PRIMARY KEY (`id`),
  ADD KEY `miner_id` (`miner_id`);

--
-- Indices de la tabla `service_requests`
--
ALTER TABLE `service_requests`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `miner_id` (`miner_id`);

--
-- Indices de la tabla `tardiness_requests`
--
ALTER TABLE `tardiness_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `miner_id` (`miner_id`);

--
-- Indices de la tabla `transport_units`
--
ALTER TABLE `transport_units`
  ADD PRIMARY KEY (`transport_id`),
  ADD UNIQUE KEY `plate` (`plate`),
  ADD KEY `assigned_driver_id` (`assigned_driver_id`);

--
-- Indices de la tabla `trip_history`
--
ALTER TABLE `trip_history`
  ADD PRIMARY KEY (`trip_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`vehicle_id`),
  ADD UNIQUE KEY `plate` (`plate`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `asistencia_vinculos`
--
ALTER TABLE `asistencia_vinculos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `companies`
--
ALTER TABLE `companies`
  MODIFY `company_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `drivers`
--
ALTER TABLE `drivers`
  MODIFY `driver_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `drivers_extended`
--
ALTER TABLE `drivers_extended`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `incidents`
--
ALTER TABLE `incidents`
  MODIFY `incident_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `miners`
--
ALTER TABLE `miners`
  MODIFY `miner_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `miners_extended`
--
ALTER TABLE `miners_extended`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `service_requests`
--
ALTER TABLE `service_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `tardiness_requests`
--
ALTER TABLE `tardiness_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `transport_units`
--
ALTER TABLE `transport_units`
  MODIFY `transport_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `trip_history`
--
ALTER TABLE `trip_history`
  MODIFY `trip_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT de la tabla `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `vehicle_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asistencia_vinculos`
--
ALTER TABLE `asistencia_vinculos`
  ADD CONSTRAINT `asistencia_vinculos_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`);

--
-- Filtros para la tabla `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`miner_id`) REFERENCES `miners` (`miner_id`);

--
-- Filtros para la tabla `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`miner_id`) REFERENCES `miners` (`miner_id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`),
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`);

--
-- Filtros para la tabla `companies`
--
ALTER TABLE `companies`
  ADD CONSTRAINT `companies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Filtros para la tabla `drivers`
--
ALTER TABLE `drivers`
  ADD CONSTRAINT `drivers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Filtros para la tabla `drivers_extended`
--
ALTER TABLE `drivers_extended`
  ADD CONSTRAINT `drivers_extended_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`);

--
-- Filtros para la tabla `incidents`
--
ALTER TABLE `incidents`
  ADD CONSTRAINT `incidents_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`);

--
-- Filtros para la tabla `miners`
--
ALTER TABLE `miners`
  ADD CONSTRAINT `miners_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Filtros para la tabla `miners_extended`
--
ALTER TABLE `miners_extended`
  ADD CONSTRAINT `miners_extended_ibfk_1` FOREIGN KEY (`miner_id`) REFERENCES `miners` (`miner_id`);

--
-- Filtros para la tabla `service_requests`
--
ALTER TABLE `service_requests`
  ADD CONSTRAINT `service_requests_ibfk_1` FOREIGN KEY (`miner_id`) REFERENCES `miners` (`miner_id`);

--
-- Filtros para la tabla `tardiness_requests`
--
ALTER TABLE `tardiness_requests`
  ADD CONSTRAINT `tardiness_requests_ibfk_1` FOREIGN KEY (`miner_id`) REFERENCES `miners` (`miner_id`);

--
-- Filtros para la tabla `transport_units`
--
ALTER TABLE `transport_units`
  ADD CONSTRAINT `transport_units_ibfk_1` FOREIGN KEY (`assigned_driver_id`) REFERENCES `drivers` (`driver_id`);

--
-- Filtros para la tabla `trip_history`
--
ALTER TABLE `trip_history`
  ADD CONSTRAINT `trip_history_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
