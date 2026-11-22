# GeoDiário

Aplicativo Android desenvolvido em Flutter para registrar fotografias com data, horário e coordenadas GPS, mantendo os dados localmente no aparelho.

## Funcionalidades

- Captura de foto pela câmera ou seleção de imagem da galeria.
- Captura automática de latitude e longitude via GPS.
- Registro de data e horário no padrão ISO-8601.
- Descrição opcional para cada registro.
- Persistência local usando SQLite (`sqflite`).
- Galeria com pesquisa por descrição, data e coordenadas.
- Ordenação por registros mais recentes ou mais antigos.
- Tela de detalhes, cópia de coordenadas e abertura no OpenStreetMap.
- Exclusão do registro no banco e do arquivo de imagem.

## Tecnologias

- Flutter / Dart
- `sqflite`
- `image_picker`
- `geolocator`
- `path_provider`
- `path`
- `uuid`
- `intl`
- `url_launcher`

## Requisitos

- Flutter SDK instalado.
- Android Studio ou Android SDK configurado.
- Um aparelho Android ou emulador.

## Como executar

1. Crie a estrutura Android padrão do Flutter:

   ```bash
   flutter create --platforms=android geodiario
   ```

2. Copie os arquivos deste repositório para a pasta `geodiario`, substituindo `pubspec.yaml`, `lib/` e `android/app/src/main/AndroidManifest.xml`.

3. Entre na pasta do projeto e execute:

   ```bash
   flutter pub get
   flutter run
   ```

4. Para gerar o APK:

   ```bash
   flutter build apk --release
   ```

   O APK será gerado em `build/app/outputs/flutter-apk/app-release.apk`.

## Estrutura SQLite

Tabela `places`:

| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | TEXT | Identificador UUID |
| `title` | TEXT | Descrição informada pelo usuário |
| `image_path` | TEXT | Caminho local do arquivo da foto |
| `loc_lat` | REAL | Latitude GPS |
| `loc_lng` | REAL | Longitude GPS |
| `date_time` | TEXT | Data/hora em ISO-8601 |

## Permissões Android

O app solicita permissão de câmera e localização durante o uso. A localização precisa estar ativada no aparelho para registrar as coordenadas.

## Observações

- Os dados ficam no armazenamento privado do aplicativo; não há envio para servidor.
- A foto é copiada para a pasta privada do app antes de seu caminho ser salvo no SQLite.
- O projeto foi preparado para Android. Não inclui pastas de iOS, Web, Windows, macOS ou Linux.
- O diretório `android/` gerado pelo comando `flutter create` pode variar conforme a versão instalada do Flutter. Por isso, recomenda-se gerar a estrutura nativa com o Flutter SDK da sua máquina e substituir o manifesto pelo arquivo deste repositório.

## Requisitos funcionais

- **RF01:** Captura de fotografia.
- **RF02:** Registro automático de data/hora e GPS, com descrição opcional.
- **RF03:** Armazenamento local em SQLite e arquivo físico da imagem.
- **RF04:** Listagem dos registros salvos.
- **RF05:** Visualização de detalhes e exclusão dos dados e da imagem.
