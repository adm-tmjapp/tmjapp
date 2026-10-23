# Histórico de build Android — TMJApp 1.0.4

**Data:** 23/10/2026  
**Versão:** `1.0.4+8`  
**Aplicativo:** TMJ App Passageiro  
**Destino:** Google Play — Teste interno

## Resultado

O Android App Bundle foi gerado e assinado com sucesso:

```text
build/app/outputs/bundle/release/app-release.aab
```

O arquivo gerado tinha aproximadamente 50 MB e foi reconhecido pelo Google Play Console como:

```text
App bundle — código 8 — versão 1.0.4
```

## Passos executados

1. Incrementar a versão no `pubspec.yaml`:

```yaml
version: 1.0.4+8
```

2. Atualizar as dependências Flutter:

```bash
cd /Users/wildsonsantos/dev-cliente/TMJ/tmjapp
flutter pub get
```

3. Confirmar que o keystore de release está configurado em:

```text
android/key.properties
android/tmjapp-upload-keystore.jks
```

Não registrar senhas, tokens ou chaves no histórico.

4. Tentar o build padrão:

```bash
flutter build appbundle --release
```

## Problema encontrado

O build padrão utilizou o Java `25.0.2` e falhou na resolução do plugin Flutter/Kotlin com erro semelhante a:

```text
Error resolving plugin [id: 'dev.flutter.flutter-plugin-loader', version: '1.0.0']
Caused by: java.lang.IllegalArgumentException: 25.0.2
```

O projeto é compatível com JDK 17. O JDK 25 não deve ser usado para este build.

## Comando correto para gerar o AAB

Forçar o JDK 17 instalado na máquina:

```bash
cd /Users/wildsonsantos/dev-cliente/TMJ/tmjapp/android

JAVA_HOME='/Users/wildsonsantos/Library/Java/JavaVirtualMachines/jbr-17.0.14/Contents/Home' \
PATH="/Users/wildsonsantos/Library/Java/JavaVirtualMachines/jbr-17.0.14/Contents/Home/bin:$PATH" \
./gradlew bundleRelease --no-daemon --console=plain --stacktrace
```

O build concluído apresentou:

```text
BUILD SUCCESSFUL
Task :app:signReleaseBundle
Task :app:bundleRelease
```

## Validações realizadas

Verificar a existência do artefato:

```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

Verificar a assinatura:

```bash
jarsigner -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab
```

## Upload no Google Play Console

1. Acessar **Testar e lançar > Teste interno**.
2. Selecionar **Criar nova versão**.
3. Enviar `app-release.aab`.
4. Confirmar o código de versão `8` e a versão `1.0.4`.
5. Informar o nome da versão:

```text
1.0.4 - Correções de homologação
```

6. Inserir as notas da versão em `pt-BR`.
7. Avançar para **Visualizar e confirmar**.
8. Conferir os artefatos e então clicar em **Salvar e publicar**.

## Observações

- O Play Console pode levar alguns minutos para otimizar o AAB antes de liberar a etapa de confirmação.
- O código de versão deve ser sempre maior que o último publicado na faixa.
- Se o Gradle travar, executar `./gradlew --stop` e repetir o build usando JDK 17.
- Nunca enviar APK/AAB de debug para o Google Play.
- Nunca registrar no repositório senhas do keystore, credenciais do Google Play ou credenciais do Asaas.
