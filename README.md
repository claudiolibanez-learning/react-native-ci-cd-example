# React Native CI/CD Example

![CI/CD Image](./images/img01.jpg)

Este repositório contém um arquivo de configuração YAML para automatizar o processo de build e deploy de um aplicativo React Native usando GitHub Actions. Siga os passos abaixo para configurar e utilizar este fluxo de trabalho:

## Pré-requisitos

- `Conta no GitHub`: Você precisa ter uma conta no GitHub para configurar e executar as GitHub Actions.

- `Projeto React Native no GitHub`: Seu projeto React Native precisa estar hospedado no GitHub, pois os fluxos de trabalho são acionados por eventos de push e pull request na branch `main`.

- `Conta no Firebase`: É necessário configurar o Firebase App Distribution com um aplicativo e grupos de testadores. 

## Passos da Pipeline

### 1. Checkout do Código

Este passo clona o repositório do GitHub para o ambiente de execução da pipeline.

### 2. Configuração do Ambiente

Este passo configura o ambiente de execução da pipeline, garantindo que as versões corretas do Java JDK e do Node.js estejam instaladas.

Variáveis:
- Nenhuma variável específica necessária.

### 3. Instalação de Dependências

Este passo instala as dependências do projeto React Native usando o npm.

Variáveis:
- Nenhuma variável específica necessária.

### 4. Configuração do Android SDK

Este passo configura o SDK do Android para o ambiente de build.

Variáveis:
- Nenhuma variável específica necessária.

### 5. Decodificação do Keystore

Este passo decodifica o keystore necessário para assinar o APK.

Variáveis:
- `ANDROID_KEYSTORE_BASE64`: Base64 do keystore Android.

### 6. Atualização da Versão do Aplicativo

Este passo atualiza a versão do aplicativo no arquivo `build.gradle`.

Variáveis:
- `github.run_number`: Número de execução do GitHub.

### 7. Build do APK

Este passo compila o APK do aplicativo React Native usando Gradle.

Variáveis:
- Nenhuma variável específica necessária.

### 8. Upload do APK para Firebase App Distribution

Este passo faz o upload do APK gerado para o Firebase App Distribution para distribuição para grupos de testadores.

Variáveis:
- `FIREBASE_APP_ID`: ID do aplicativo Firebase.

- `FIREBASE_CREDENTIAL_FILE_CONTENT`: Conteúdo do arquivo de credenciais do Firebase.

## Exemplo de Script

```bash
name: Build and Deploy React Native App

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    env:
      ANDROID_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
      ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
      ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}

    steps:
    - name: Checkout code
      uses: actions/checkout@v4.1.5

    - name: Setup Java JDK
      uses: actions/setup-java@v4.2.1
      with:
        distribution: 'adopt'
        java-version: '17'
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: 20.x

    - name: Install dependencies
      run: npm install

    - name: Setup Android SDK
      uses: android-actions/setup-android@v2

    - name: Decode keystore
      env:
        ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
      run: |
        echo "$ANDROID_KEYSTORE_BASE64" | base64 --decode > android/app/android-production.jks

    - name: Bump version
      uses: chkfung/android-version-actions@v1.2.2
      with:
        gradlePath: android/app/build.gradle
        versionCode: ${{github.run_number}}

    - name: Build Android APK
      run: |
        cd android
        ./gradlew assembleRelease

    - name: Upload APK to Firebase App Distribution
      uses: wzieba/Firebase-Distribution-Github-Action@v1
      with:
        appId: ${{secrets.FIREBASE_APP_ID}}
        serviceCredentialsFileContent: ${{ secrets.FIREBASE_CREDENTIAL_FILE_CONTENT }}
        groups: testers
        file: android/app/build/outputs/apk/release/app-release.apk
```

### Adicionar o Keystore ao GitHub Secrets

1. Navegue até a página do seu repositório no GitHub.

2. Vá para Settings > Secrets and variables > Actions.

3. Adicione um novo secret chamado KEYSTORE_BASE64 e faça o upload do seu keystore codificado em base64:

- No terminal, codifique o keystore em base64:
```
$ base64 -w 0 android/app/my-release-key.keystore > my-release-key.keystore.base64
```
- Copie o conteúdo do arquivo `my-release-key.jks.base64` e adicione ao secret `ANDROID_KEYSTORE_BASE64`.

4. Adicione os outros secrets necessários:

- `ANDROID_KEYSTORE_PASSWORD`: A senha do keystore.

- `ANDROID_KEY_ALIAS`: O alias do keystore.

- `ANDROID_KEY_PASSWORD`: A senha da chave.

### Configurando Variáveis de Ambiente no GitHub Secrets

Adicione os seguintes secrets:

- `ANDROID_KEYSTORE_PASSWORD`

- `ANDROID_KEY_ALIAS`

- `ANDROID_KEY_PASSWORD`

### Atualizar o Arquivo `build.gradle`

Certifique-se de que o arquivo android/app/build.gradle está configurado para usar essas variáveis de ambiente:

```groovy
android {
    ...
    signingConfigs {
        release {
            storeFile file("android-production.jks")
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    ...
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

## Gerando uma Keystore do Android

Para gerar uma keystore do Android, siga o passo a passo abaixo:

1. **Abra o Terminal:**
   - Abra o terminal no seu sistema operacional.

2. **Navegue até o Diretório de Chaves do Android (opcional):**
   - Se desejar, navegue até o diretório onde deseja salvar a keystore. Caso contrário, a keystore será salva no diretório atual do terminal.

3. **Execute o Comando Keytool:**
   - No terminal, execute o comando `keytool` para acessar a ferramenta de geração de chaves do Java.

4. **Gere a Keystore:**
   - Para gerar uma nova keystore, use o seguinte comando:
     ```bash
     sudo keytool -genkeypair -v -keystore nome_do_arquivo.keystore -alias alias_da_chave -keyalg RSA -keysize 2048 -validity 10000

     ## ou

     sudo keytool -genkeypair -v -keystore nome_do_arquivo.jks -alias alias_da_chave -keyalg RSA -keysize 2048 -validity 10000
     ```

5. **Preencha os Detalhes Solicitados:**
   - Você será solicitado a preencher os seguintes detalhes:
     - Nome e sobrenome.
     - Nome da unidade organizacional.
     - Nome da organização.
     - Nome da cidade/localidade.
     - Nome do estado/província.
     - Código de duas letras do país.

6. **Escolha Senhas Fortes:**
   - Escolha senhas fortes para a keystore e para a chave. Você precisará delas para assinar o APK posteriormente.

7. **Confirme os Detalhes:**
   - Após preencher todos os detalhes, confirme se as informações estão corretas.

8. **Salve as Senhas em um Local Seguro:**
   - Anote e armazene as senhas da keystore e da chave em um local seguro. Elas serão necessárias para assinar o APK do seu aplicativo Android.

9. **Verifique a Criação da Keystore:**
   - Após a conclusão do processo, verifique se a keystore foi criada com sucesso no diretório especificado.

10. **Converta a Keystore para Base64 (opcional):**
    - Se desejar usar a keystore em GitHub Actions ou outro ambiente de integração contínua, você pode converter o arquivo para Base64 para armazená-lo como um segredo.

11. **Use a Keystore para Assinar o APK:**
    - Finalmente, use a keystore gerada para assinar o APK do seu aplicativo Android durante o processo de build.

Certifique-se de armazenar as senhas de forma segura e de usar uma keystore válida ao assinar o APK do seu aplicativo.

## Gerando base64 do arquivo Keystore

```
$ base64 -i android-production.jks -o android-production.jks.base64 
```

## Configurando o Firebase para Distribuição de Aplicativos

Para configurar o Firebase e distribuir seu aplicativo utilizando o Firebase App Distribution, siga os passos abaixo:

1. **Crie um Projeto no Firebase:**
   - Acesse o [Console do Firebase](https://console.firebase.google.com/) e crie um novo projeto.
   - Siga as instruções para configurar o projeto, incluindo a seleção do nome do projeto e a aceitação dos termos.

2. **Registre o Aplicativo Android no Firebase:**
   - Após criar o projeto, registre seu aplicativo Android no Firebase.
   - Você precisará fornecer o nome do pacote do seu aplicativo, que geralmente é algo como `com.seuapp.nome`.

3. **Baixe o arquivo de Configuração do Firebase:**
   - Após registrar o aplicativo, baixe o arquivo de configuração do Firebase (`google-services.json`) para o seu projeto Android.
   - Este arquivo contém as informações necessárias para integrar seu aplicativo com os serviços do Firebase.

4. **Adicione o Arquivo de Configuração ao Seu Projeto:**
   - Copie o arquivo `google-services.json` baixado para o diretório `android/app/` do seu projeto React Native.

5. **Obtenha o ID do Aplicativo (appId):**
   - No Console do Firebase, vá para as configurações do seu projeto.
   - Em "Geral", você encontrará o ID do projeto, que é o `appId` que você usará nas configurações do GitHub Actions.

6. **Crie Credenciais de Serviço (Service Credentials):**
   - No Console do Firebase, vá para as configurações do projeto e selecione a guia "Contas de Serviço".
   - Crie uma nova chave de API e faça o download do arquivo JSON das credenciais.
   - Este arquivo contém as credenciais de serviço necessárias para autenticar a comunicação com o Firebase.

7. **Converta o Arquivo JSON para Base64 (opcional):**
   - Se você planeja usar as credenciais de serviço no GitHub Actions, você pode converter o arquivo JSON para Base64 para armazená-lo como um segredo.
   - Use uma ferramenta ou um comando no terminal para converter o arquivo para Base64: `base64 arquivo.json`.

8. **Configure as Variáveis de Ambiente no GitHub:**
   - Configure as variáveis de ambiente `FIREBASE_APP_ID` e `FIREBASE_CREDENTIAL_FILE_CONTENT` no repositório do GitHub para armazenar o `appId` e o conteúdo do arquivo de credenciais do Firebase, respectivamente.

9. **Atualize a Pipeline de Build e Deploy:**
   - Certifique-se de atualizar a pipeline de build e deploy do seu projeto React Native para usar as variáveis de ambiente e os segredos configurados para integração com o Firebase App Distribution.

10. **Teste o Fluxo de Build e Deploy:**
    - Após configurar o Firebase e as variáveis de ambiente, faça um teste executando uma build e deploy do seu aplicativo React Native para garantir que tudo esteja funcionando conforme o esperado.

Seguindo este guia, você será capaz de configurar o Firebase e distribuir seu aplicativo utilizando o Firebase App Distribution de forma eficiente.