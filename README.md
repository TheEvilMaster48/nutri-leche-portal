# Nutri Leche Portal - Flutter

Portal de Empleados para Nutri Leche Ecuador desarrollado en Flutter/Dart.

## Características

- ✅ Sistema de autenticación con registro de usuarios
- ✅ Gestión de eventos con imágenes y documentos
- ✅ Sistema de notificaciones en tiempo real
- ✅ Chat interno entre empleados
- ✅ Gestión de recursos y documentos descargables en PDF
- ✅ Perfil de usuario editable
- ✅ Almacenamiento local con SharedPreferences

## Estructura del Proyecto

\`\`\`
lib/
├── core/                      # Funcionalidades principales
│   ├── app_localizations.dart
│   ├── locale_provider.dart
│   ├── notification_banner.dart
│   └── realtime_manager.dart
├── models/                    # Modelos de datos
│   ├── chat.dart
│   ├── evento.dart
│   ├── mensaje.dart
│   ├── notificacion.dart
│   ├── pais.dart
│   ├── recurso.dart
│   └── usuario.dart
├── screens/                   # Pantallas de la aplicación
│   ├── acerca_screen.dart
│   ├── ayuda_screen.dart
│   ├── chat.dart
│   ├── chat_detalle.dart
│   ├── configuracion_screen.dart
│   ├── crear_evento.dart
│   ├── crear_publicacion.dart
│   ├── editar_perfil.dart
│   ├── eventos.dart
│   ├── login.dart
│   ├── menu.dart
│   ├── noticias.dart
│   ├── notificaciones.dart
│   ├── nuevo_chat.dart
│   ├── perfil.dart
│   ├── recursos.dart
│   └── registro.dart
├── services/                  # Servicios y lógica de negocio
│   ├── validators/
│   │   ├── empleado_validator.dart
│   │   └── telefono_validator.dart
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── evento_service.dart
│   ├── global_notifier.dart
│   ├── language_service.dart
│   ├── notificacion_service.dart
│   ├── recurso_service.dart
│   └── usuario_service.dart
├── widget/                    # Widgets reutilizables
│   └── menuItem.dart
└── main.dart                  # Punto de entrada
\`\`\`

## Instalación

1. Asegúrate de tener Flutter instalado (versión 3.0.0 o superior)
2. Clona el repositorio
3. Ejecuta `flutter pub get` para instalar las dependencias
4. Ejecuta `flutter run` para iniciar la aplicación

## Dependencias Principales

- **provider**: Gestión de estado
- **shared_preferences**: Almacenamiento local
- **pdf**: Generación de documentos PDF
- **printing**: Descarga e impresión de PDFs
- **image_picker**: Selección de imágenes
- **file_picker**: Selección de archivos

## Funcionalidades por Módulo

### Autenticación
- Registro de usuarios con validación completa
- Login con credenciales guardadas localmente
- Validación de código de empleado
- Selector de país con bandera para teléfono

### Eventos
- Crear eventos con título, descripción y fecha
- Adjuntar imágenes y documentos
- Editar eventos existentes
- Validación de fechas (no permite fechas pasadas)

### Notificaciones
- Notificaciones automáticas por cada acción
- Marcar como leídas
- Indicador de notificaciones no leídas
- Detalles completos de cada acción realizada

### Chat
- Lista de contactos
- Chat en tiempo real
- Interfaz estilo WhatsApp
- Envío de mensajes

### Recursos
- Documentos de la empresa descargables
- Editor de contenido antes de descargar
- Generación de PDFs funcional
- Múltiples categorías de documentos

### Perfil
- Visualización de información personal
- Edición de datos del usuario
- Configuración de la cuenta
- Ayuda y soporte

## Notas de Desarrollo

- Todos los datos se almacenan localmente usando SharedPreferences
- Las notificaciones se generan automáticamente para cada acción
- Los PDFs se pueden editar antes de descargar
- El sistema valida fechas para no permitir eventos en el pasado
- La interfaz sigue el diseño proporcionado con colores específicos

## Colores del Sistema

- Azul (#3B82F6): Eventos y principal
- Cyan (#22D3EE): Notificaciones
- Verde (#4ADE80): Chat
- Morado (#A78BFA): Recursos/Perfil
- Rojo (#FF6B6B): Alertas

## Autor

Desarrollado para Nutri Leche Ecuador
