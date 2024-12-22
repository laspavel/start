## Добавление пользователя ##

add_k8s_user.sh - Создание пользователя (с сертификатом) и подключение к нему необходимых прав доступа (В общем случае привязка к нему отдельного namespace)
Для работы необходимы CA сертификат и ключ (crt и key) кластера. 

### Как найти CA-файлы:  ###

1. Minikube:
/etc/kubernetes/pki/ca.crt
/etc/kubernetes/pki/ca.key

2. K3s:
/var/lib/rancher/k3s/server/tls/client-ca.crt
/var/lib/rancher/k3s/server/tls/client-ca.key

3. Kind:
/etc/kubernetes/pki/ca.crt
/etc/kubernetes/pki/ca.key

4. Самостоятельная установка Kubernetes:
/etc/kubernetes/pki/ca.crt
/etc/kubernetes/pki/ca.key

### Что делать, если CA-файлов нет ? ###

Если CA-файлы недоступны и вы используете управляемый кластер (например, EKS), настройка доступа пользователей выполняется по-другому.
Через Kubernetes RBAC и токены. Вы можете создать ServiceAccount для пользователя и выдать ему токен:

```
kubectl create namespace user1
kubectl create serviceaccount user1 -n user1
kubectl create rolebinding user1-binding --role=cluster-admin --serviceaccount=user1:user1 -n user1
kubectl get secret $(kubectl get serviceaccount user1 -n user1 -o jsonpath='{.secrets[0].name}') -n user1 -o jsonpath='{.data.token}' | base64 --decode
```

## Удаление пользователя ##
del_k8s_user.sh - Удение пользователя и namespace созданного скриптом add_k8s_user

---
