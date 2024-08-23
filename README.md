
# **Desarrollando Videojuegos Dinámicos en Flutter con Flame: Técnicas y Estrategias**

## **Aqui veremos una forma de crear un videojuego multiplataforma  en 2D**

### **1. Introducción**

#### **Objetivo del Taller**

- Se enseñará a crear un juego sencillo con Flutter y Flame, donde un personaje podrá moverse en cuatro direcciones dentro de un mundo con un fondo, utilizando una animación de sprite para el personaje, y con un obstáculo en el centro que detecta colisiones.

#### **Presentación de Flame**

- **Flame**: Un motor de juegos 2D para Flutter que facilita la creación de juegos con herramientas para gráficos, sonido, y entrada de usuario.
- **Flutter + Flame**: Combina la potencia de Flutter con las capacidades de Flame para desarrollar juegos móviles.

#### **Requisitos Previos**

- **Instalación de Flutter**: Asegúrate de tener Flutter instalado o haz uso de herramientas como:].
- **IDE Configurado**: Recomienda utilizar Visual Studio Code o Android Studio.

---

### **2. Configuración del Proyecto**

#### **Crear un Proyecto en Flutter**

- **Comando para Crear el Proyecto**:

     ```bash
     flutter create my_game
     cd my_game
     ```

- **Abrir el Proyecto**: Utiliza un IDE para abrir el proyecto recién creado.

#### **Agregar Flame al Proyecto**

- **Modificar `pubspec.yaml`**: Añade la dependencia de Flame:

     ```yaml
     dependencies:
       flutter:
         sdk: flutter
       flame: ^1.18.0 #Usar la última versión
     ```

- **Instalación de Dependencias**: Ejecuta `flutter pub get` para instalar Flame.

#### **Estructura del Proyecto**

- **Explicación Básica**:
  - `lib/main.dart`: Punto de entrada del juego.
  - `lib/players/player.dart`: Donde crearemos las caracteristicas de nuestro jugador.
  - `lib/obstacles/obstacle.dart`: Crearemos el obstaculo.
  - `assets/`: Directorio donde se colocarán los archivos de imágenes y sonidos.

---

### **3. Creación del Fondo del Mundo**

### - Puede ser con un color solido, o imagenes o un tilemap

### Con un color solido

- **Cargar y Dibujar el Fondo**:
  - En `lib/main.dart`, crea una clase `GameWorld` que extienda de `FlameGame`:

       ```dart
       import 'package:flame/game.dart';
       import 'package:flame/components.dart';

       class GameWorld extends FlameGame {
         late SpriteComponent background;

         @override
         Future<void> onLoad() async {
           // Crear un fondo de color sólido
            final background = RectangleComponent(
            size: size,  // Tamaño del fondo igual al tamaño de la pantalla
            paint: Paint()..color = Colors.blue,  // Color del fondo (puedes cambiarlo a cualquier color)
            );

            add(background);  // Añadir el fondo al juego
         }
       }
       ```

### Con una imagen

#### **Agregar el Archivo de Imagen de Fondo**

- **Descargar o Crear un Fondo**: Utiliza una imagen simple para el fondo. Coloca la imagen en la carpeta `assets/images/`.
- **Actualizar `pubspec.yaml`**:

     ```yaml
     assets:
       - assets/images/background.png
     ```

#### **Implementar el Fondo en el Juego**

- **Cargar y Dibujar el Fondo**:
  - En `lib/main.dart`, crea una clase `GameWorld` que extienda de `FlameGame`:

       ```dart
       import 'package:flame/game.dart';
       import 'package:flame/components.dart';

       class GameWorld extends FlameGame {
         late SpriteComponent background;

         @override
         Future<void> onLoad() async {
           // Cargar el fondo
           background = SpriteComponent()
             ..sprite = await loadSprite('background.png')
             ..size = size;  // Ajusta el tamaño del fondo al tamaño de la pantalla

           add(background);
         }
       }
       ```

### Luego procedemos a inicializar el juego en el main

- **Inicializar el Juego**:
  - En `main.dart`, reemplaza el contenido del `main()` para ejecutar `GameWorld`:

       ```dart
       void main() {
         runApp(GameWidget(game: GameWorld()));
       }
       ```

---

### **4. Creación del Personaje con Sprite Animation**

#### **Importar y Configurar el Sprite Sheet del Personaje**

- **Agregar el Sprite Sheet**: Coloca la imagen del sprite sheet en `assets/images/`.
- **Actualizar `pubspec.yaml`**:

     ```yaml
     assets:
       - assets/images/player_spritesheet.png
     ```

#### **Crear la Clase `Player` con Sprite Animation**

- **Definición del Personaje con Animación**:
  - Crea una clase `Player` que extienda de `SpriteAnimationGroupComponent`: (Adicional se cargan las animaciones pertinentes del personaje.)

       ```dart
       class Player extends SpriteAnimationGroupComponent with HasGameRef<GameWorld>, KeyboardHandler, CollisionCallbacks {

         @override
        Future<void> onLoad() async {
            await _loadAnimations();

            size = Vector2(128, 128); // Tamaño del personaje en pantalla
            position = Vector2(0, game.size.y / 2); // Posicion inicial del personaje

            return super.onLoad();
        }

        Future<void> _loadAnimations() async {
            final spriteSheetIdle = SpriteSheet(
            image: await game.images.load('1_Cat_Idle-Sheet.png'), //Cargamos el SpriteSheet
            srcSize: Vector2(32, 32), //Tamaño de cada frame en el SpriteSheet
            );

            final spriteSheetRun = SpriteSheet(
            image: await game.images.load('2_Cat_Run-Sheet.png'), //Cargamos el SpriteSheet
            srcSize: Vector2(32, 32), //Tamaño de cada frame en el SpriteSheet
            );

            animations = {
            'idle': spriteSheetIdle.createAnimation(
                stepTime: 0.1, //Tiempo de cada frame en la animacion
                from: 0, //Desde que imagen de la final
                to: 8, // Hasta que imagen de la final
                row: 0, //Cual Fila será la animación
            ),
            'run': spriteSheetRun.createAnimation(
                stepTime: 0.1,
                from: 0,
                to: 10,
                row: 0,
            ),
            };

            current = 'idle'; //Con cual animacion iniciará.
        }
       }
       ```

- **Actualizamos Movimiento y Animación del personaje**:
  - Se añade el metodo `update` que realiza en un `dt` la actualizacion del personaje, alli actualizamos el movimiento y las animaciones,  adicional añadimos el  `onKeyEvent` para detectar las teclas del dispositivo:

    ```dart
       class Player extends SpriteAnimationGroupComponent with HasGameRef<GameWorld>, KeyboardHandler, CollisionCallbacks {
            Vector2 velocity = Vector2.zero();
            Vector2 movement = Vector2.zero();

            @override
            Future<void> onLoad() async {
                await _loadAnimations();

                size = Vector2(128, 128);
                position = Vector2(0, game.size.y / 2);

                return super.onLoad();
            }

            @override
            void update(double dt) { 
                super.update(dt);
                _updateAnimation();
                _updateMovement(dt);
            }

            Future<void> _loadAnimations() async {
                // (Mantén el resto del código igual)
            }

            void _updateAnimation() {
                if (velocity != Vector2.zero()) {
                    if (velocity.x < 0 && scale.x > 0) {
                        flipHorizontallyAroundCenter();
                    } else if (velocity.x > 0 && scale.x < 0) {
                        flipHorizontallyAroundCenter();
                    }
                    current = 'run';
                } else {
                    current = 'idle';
                }
            }

            void _updateMovement(double dt) {
                velocity.x = movement.x * 200;
                velocity.y = movement.y * 200;
                position.x += velocity.x * dt;
                position.y += velocity.y * dt;
            }

            @override
            bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
                movement.x = 0;
                movement.y = 0;

                if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
                    movement.y += -1;
                } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
                    movement.y += 1;
                } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
                    movement.x += -1;
                } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
                    movement.x += 1;
                }

                return super.onKeyEvent(event, keysPressed);
            }
        }
       ```

#### **Agregar el Personaje al Mundo**

- **Añadir al Juego**:
  - En la clase `GameWorld`, agrega el `Player` al juego:

       ```dart
       class GameWorld extends FlameGame with HasKeyboardHandlerComponents{
         late Player player;

         @override
         Future<void> onLoad() async {
           background = SpriteComponent()
             ..sprite = await loadSprite('background.png')
             ..size = size;

           player = Player();
           add(background);
           add(player);
         }
       }
       ```

### **5. Agregar el Obstáculo**

#### **Crear la Clase `Obstacle`**

- **Definir un Obstáculo Estático**:
  - Crea una clase `Obstacle` que extienda de `PositionComponent`:

       ```dart
        class Obstacle extends PositionComponent
            with CollisionCallbacks, HasGameRef<GameWorld> {
            final _defaultColor = Colors.cyan;
            late Paint defaultPaint;

            @override
            Future<void> onLoad() async {
                size = Vector2(200, 100); //Tamaño del obstaculo
                position = game.size / 2 - size / 2; //Posicion del obstaculo en pantalla
                defaultPaint = Paint()
                    ..color = _defaultColor
                    ..style = PaintingStyle.fill; //Se genera el paint que utilizaremos para dibujar el obstaculo

            }

            @override
            void render(Canvas canvas) {
                super.render(canvas);
                canvas.drawRect(size.toRect(), defaultPaint);
            }
        }
       ```

#### **Agregar el Obstáculo al Mundo**

- **Añadir el Obstáculo**:
  - En `GameWorld`, añade el obstáculo junto con el personaje:

       ```dart
       class GameWorld extends FlameGame with HasKeyboardHandlerComponents{
         late Player player;
         late Obstacle obstacle;

         @override
         Future<void> onLoad() async {
           background = SpriteComponent()
             ..sprite = await loadSprite('background.png')
             ..size = size;

           player = Player();
           obstacle = Obstacle();

           add(background);
           add(obstacle);
           add(player);
         }
       }
       ```

---

### **6. Detección de Colisiones**

#### **Implementar Detección de Colisiones en `Player`**

- **Añadir `CollisionCallbacks`**:
  - Modificamos `Player` para implementar la colisión:

       ```dart
       class Player extends SpriteAnimationComponent with HasGameRef<GameWorld>, CollisionCallbacks {
        late ShapeHitbox shapeHitbox;

        @override
        Future<void> onLoad() async {
            await _loadAnimations();

            size = Vector2(128, 128);
            position = Vector2(0, game.size.y / 2);

            shapeHitbox = RectangleHitbox( //Rectangulo interno que detecte la colisión.
                size: Vector2(70, 80), //Tamaño del personaje dentro de su cuadro de frame.
                position: Vector2(24, 34), //Posicion con respecto a la caja padre.
                collisionType: CollisionType.passive,
            );

            add(shapeHitbox);

            return super.onLoad();
        }

         // (Mantén el resto del código igual)

        @override
        void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
            super.onCollisionStart(intersectionPoints, other);

            if (other is Obstacle) {
                position = Vector2(0, game.size.y / 2);
            }
        }
       }
    ```

  - Modificamos `Obstacle` para implementar la colisión:

    ```dart
       class Obstacle extends PositionComponent with CollisionCallbacks {
            late ShapeHitbox hitbox;

            @override
            Future<void> onLoad() async {
                // (Mantén el resto del código igual)

                hitbox = RectangleHitbox(); //El recuadro que detecta las colisiones
                add(hitbox); //No parametros = Condiciones padre
            }

         // (Mantén el resto del código igual)
       }
       ```

#### **Habilitar la Detección de Colisiones en `GameWorld`**

- **Agregar el Mixin**:
  - En `GameWorld`, añade el mixin `HasCollisionDetection` para habilitar las colisiones:

       ```dart
       class GameWorld extends FlameGame with with HasKeyboardHandlerComponents, HasCollisionDetection  {
         // (Mantén el resto del código igual)
       }
       ```

---

### **7. Integración y Pruebas**

#### **Unir Todo**

- **Añadir Todos los Componentes**: Asegúrate de que el fondo, el personaje (con la animación

 de sprite) y el obstáculo estén todos añadidos y visibles en la pantalla.

- **Ejecutar el Juego**: Ejecuta el proyecto en un emulador o dispositivo físico para verificar que el personaje se mueva y las colisiones funcionen correctamente.

#### **Depuración y Resolución de Problemas**

- **Técnicas Básicas**:
  - Usa `print()` para depurar posiciones y estados.
  - Asegúrate de que los métodos `update` y `onCollisionStart` estén funcionando como se espera.

---
