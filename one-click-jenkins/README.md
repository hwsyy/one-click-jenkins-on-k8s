## 基于EKS（K8S）一键部署Jenkins

----
### 部署
命令示例
```sh
$ ./common_template/deploy.sh --help
Usage: 
  Deploy jenkins server in eks
  Need kubectl installed and admin permisson on current cluster
Parameters:
    --namespace  <namespace>
    --efs  <efs id>
    --cert <path to tls cert file>
    --key  <path to tls key file>

./deploy.sh  --namespace jenkins-stg --efs fs-d23e74d6 --cert /path/to/server.crt --key /path/to/server.key
```
**参数说明：**
--namespace: the namespace that you want deploy jenkins server
--efs: the efs id which jenkins will use it as storageclass backend
--cert: the path of https certificate
--key: the path of key binded with https certificate

**一键部署的依赖项：**
1. efs csi driver 事先部署好
2. ingress nginx controller 可用（服务暴露是通过ingress nginx做的）


**备注：**
如果不需要一键部署或有者一些依赖的条件不满足的话，其实也可以自己把template中自己需要的部分单独拿出来改成yaml文件，把文件中的变量改成实际值就可以了

**参考资源:**
在做这个一键部署的过程了很多地方参考了阳明大佬的博客，我这里只写了如何基于k8s部署jenkins，但是具体的使用没有说明，可以参考大佬的博客，里面有比较详细的介绍。这里贴上原文链接：
[基于 Jenkins、Gitlab、Harbor、Helm 和 Kubernetes 的 CI/CD(一)](https://www.qikqiak.com/post/complete-cicd-demonstrate-1/)  
[基于 Jenkins、Gitlab、Harbor、Helm 和 Kubernetes 的 CI/CD(二)](https://www.qikqiak.com/post/complete-cicd-demonstrate-2/)
----
### 在EKS中使用EFS作为存储的几个配置
1. EFS CSI 安装
参考：https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html 
在EKS中使用EFS作为存储时，需要在EKS中安装csi driver
创建storageclass之前需要先执行以下命令，安装驱动
```sh
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.0"
```

2. 创建EFS、配置sg（安全组）、AZ和挂载点
官方指导链接:
https://aws.amazon.com/cn/premiumsupport/knowledge-center/eks-persistent-storage/


----
#### K8S Pods HPA
这依赖于metrics server采集集群的性能数据
配置--max参数的时候需要考虑对应数量的pod所需的计算资源之和小于EKS node总资源的90%（剩余的10%是给k8s本身调度使用的）.
```sh
kubectl autoscale deployment <deployment name>--cpu-percent=75 --min=l --max=5
```

----
### Nginx Ingress IP 和路径访问控制
https://blog.aliasmee.com/post/kubernetes-nginx-ingress-block-ip-whitelist/

----
### Nginx Ingress Session 固定
https://www.jianshu.com/p/ff0463ba7482
https://kaerser.github.io/2019/04/30/nginx-ingress%E9%85%8D%E7%BD%AE%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81/
