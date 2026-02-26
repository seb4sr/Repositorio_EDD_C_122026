use strict;
use warnings;
use Gtk3 -init;

my $window = Gtk3::Window->new('toplevel'); #Crea una nueva ventana de nivel superior

$window->set_title("Login EDD"); #Establece el título de la ventana
$window->set_default_size(400, 250);#Establece el tamaño predeterminado de la ventana a 400 píxeles de ancho y 250 píxeles de alto
$window->signal_connect( destroy => sub { Gtk3->main_quit; });#Conecta la señal destroy para finalizar la aplicación cuando se cierra la ventana de login

my $box = Gtk3::Box->new('vertical', 10);#Crea un nuevo contenedor de caja vertical con un espacio de 10 píxeles entre los elementos
$box->set_margin_top(20);#Establece el margen superior del contenedor de caja a 20 píxeles
$box->set_margin_bottom(20);#Establece el margen inferior del contenedor de caja a 20 píxeles
$box->set_margin_start(20);#Establece el margen izquierdo del contenedor de caja a 20 píxeles
$box->set_margin_end(20);#Establece el margen derecho del contenedor de caja a 20 píxeles   

my $user_label = Gtk3::Label->new("Usuario:");#Crea una nueva etiqueta con el texto "Usuario:"
my $user_entry = Gtk3::Entry->new();#Crea un nuevo campo de entrada para el nombre de usuario

my $pass_label = Gtk3::Label->new("Contraseña:");#Crea una nueva etiqueta con el texto "Contraseña:"
my $pass_entry = Gtk3::Entry->new();#Crea un nuevo campo de entrada para la contraseña
$pass_entry->set_visibility(0);#Establece la visibilidad del campo de entrada de contraseña a 0 para ocultar los caracteres ingresados

my $login_button = Gtk3::Button->new("Login");#Crea un nuevo botón con el texto "Login"

my $error_label = Gtk3::Label->new("");#Crea una etiqueta vacía para mostrar mensajes de error al usuario
$error_label->set_halign('start');#Alinea la etiqueta de error hacia la izquierda para que se vea debajo del botón
$error_label->set_markup("<span foreground='red'></span>");#Define el formato en color rojo para los mensajes de error

$box->pack_start($_, 0, 0, 5) for (
    $user_label,
    $user_entry,
    $pass_label,
    $pass_entry,
    $login_button,
    $error_label
); #Agrega los widgets al contenedor de caja con un espacio de 5 píxeles entre ellos
#Los parametros 0, 0 indican que los widgets no deben expandirse ni llenarse, manteniendo su tamaño natural

$login_button->signal_connect(clicked => sub {#Conecta el evento clic del botón Login con la validación de credenciales
    my $usuario = $user_entry->get_text();#Obtiene el texto ingresado en el campo de usuario
    my $contrasena = $pass_entry->get_text();#Obtiene el texto ingresado en el campo de contraseña

    if ($usuario eq 'admin' && $contrasena eq '123') {#Verifica si el usuario y la contraseña coinciden con las credenciales válidas
        $error_label->set_markup("<span foreground='red'></span>");#Limpia el mensaje de error cuando las credenciales son correctas

        my $home_window = Gtk3::Window->new('toplevel');#Crea la nueva ventana que se mostrará después del login exitoso
        $home_window->set_title("Panel Principal");#Establece el título de la ventana posterior al login
        $home_window->set_default_size(400, 200);#Establece el tamaño predeterminado de la nueva ventana
        my $home_destroy_handler = $home_window->signal_connect( destroy => sub { Gtk3->main_quit; });#Guarda el identificador de la señal destroy para controlar el cierre al regresar al login

        my $home_box = Gtk3::Box->new('vertical', 10);#Crea un contenedor vertical para organizar el contenido de la nueva ventana
        $home_box->set_margin_top(20);#Establece margen superior para separar los elementos del borde
        $home_box->set_margin_bottom(20);#Establece margen inferior para separar los elementos del borde
        $home_box->set_margin_start(20);#Establece margen izquierdo para separar los elementos del borde
        $home_box->set_margin_end(20);#Establece margen derecho para separar los elementos del borde

        my $saludo_boton = Gtk3::Button->new("Saludar a $usuario");#Crea un botón que saluda al usuario autenticado
        $saludo_boton->signal_connect(clicked => sub {#Conecta el clic del botón de saludo para mostrar un mensaje al usuario
            my $dialogo = Gtk3::MessageDialog->new(#Crea un cuadro de diálogo informativo para mostrar el saludo
                $home_window,
                'destroy-with-parent',
                'info',
                'ok',
                "Hola, $usuario"
            );
            $dialogo->run;#Muestra el diálogo y espera la interacción del usuario
            $dialogo->destroy;#Destruye el diálogo después de cerrarlo para liberar recursos
        });

        my $regresar_boton = Gtk3::Button->new("Regresar al inicio de sesión");#Crea un botón para volver a la ventana de login
        $regresar_boton->signal_connect(clicked => sub {#Conecta el clic para regresar a la pantalla de inicio de sesión
            #Esta siguiente linea es crucial para evitar que al regresar al login se cierre toda la aplicación, ya que el handler de destroy de la ventana principal se desconecta para permitir que solo se cierre la ventana actual sin afectar el ciclo principal de la aplicación
            $home_window->signal_handler_disconnect($home_destroy_handler);#Desconecta el cierre por defecto para no terminar la app al volver al login
            $home_window->destroy;#Cierra la ventana principal cuando el usuario decide regresar
            $user_entry->set_text("");#Limpia el campo de usuario al regresar al formulario de login
            $pass_entry->set_text("");#Limpia el campo de contraseña al regresar al formulario de login
            $window->show_all;#Muestra nuevamente la ventana de login para completar la navegación entre ventanas
        });

        $home_box->pack_start($saludo_boton, 0, 0, 5);#Agrega el botón de saludo al contenedor de la nueva ventana
        $home_box->pack_start($regresar_boton, 0, 0, 5);#Agrega el botón para regresar al login en la nueva ventana
        $home_window->add($home_box);#Agrega el contenedor principal a la nueva ventana
        $home_window->show_all;#Muestra todos los elementos de la nueva ventana

        $window->hide;#Oculta la ventana de login cuando la autenticación es correcta para poder mostrarla de nuevo al regresar
    } else {#Se ejecuta cuando alguna credencial es incorrecta
        $error_label->set_markup("<span foreground='red'>User/pass incorrecta</span>");#Muestra el mensaje de error en rojo debajo del botón Login
    }
});

$window->add($box);#Agrega el contenedor de caja a la ventana
$window->show_all;#Muestra todos los widgets en la ventana
Gtk3->main;#Inicia el bucle principal de la aplicación para que la ventana permanezca abierta y responda a eventosT