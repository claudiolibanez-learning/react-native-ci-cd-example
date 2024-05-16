# React Native CI/CD Example


1. Navegue até a página do seu repositório no GitHub.

2. Vá para Settings > Secrets and variables > Actions.

3. Adicione um novo secret chamado KEYSTORE_BASE64 e faça o upload do seu keystore codificado em base64:

```
$ base64 -w 0 android/app/android-production.keystore > android-production.keystore.base64
```

## Gerar a Keystore

```
$ cd android/app
```

```
$ sudo keytool -genkey -v -keystore production.keystore -alias production -keyalg RSA -keysize 2048 -validity 10000

$ sudo keytool -genkey -v -keystore production.jks -alias production -keyalg RSA -keysize 2048 -validity 10000
```

```
Enter keystore password: 
teste123

Re-enter new password:
teste123
```

## Gerar base64 do arquivo Keystore

```
$ base64 -i android-production.jks -o android-production.jks.base64 
```

