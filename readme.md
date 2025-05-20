ssh:
```bash
#Port fordwarding para webUI
ssh -L 8080:127.0.0.1:9999 -i "pablo-rejo-keys-ec2.pem" ubuntu@18.101.59.179

# port fordwarding para acceder a otras VM:
ssh -L 5000:10.0.0.188:22 -i "pablo-rejo-keys-ec2.pem" ubuntu@18.101.59.179
ssh -p 5000 -i "pablo-rejo-keys-ec2.pem" ubuntu@localhost
```


descargar archivos:
```bash
scp -i "pablo-rejo-keys-ec2.pem" -r ubuntu@51.92.193.237:/etc/open5gs C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\files

#Files config UEs 
scp -i "pablo-rejo-keys-ec2.pem" -r ubuntu@51.94.3.109:/home/ubuntu/UERANSIM/config C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\files

#Logs UEs 
scp -i "pablo-rejo-keys-ec2.pem" -r ubuntu@51.94.3.109:/home/ubuntu/logs C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\files

#Files config gnB 
scp -i "pablo-rejo-keys-ec2.pem" -r ubuntu@51.92.175.177:/home/ubuntu/UERANSIM/config C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\files

# Files open5g core
scp -i "pablo-rejo-keys-ec2.pem" -r ubuntu@18.101.59.179:/home/ubuntu/files/open5gs C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\files


#  Files config open5g core
scp -i "pablo-rejo-keys-ec2.pem" -r ubuntu@18.101.59.179:/home/ubuntu/open5gs/install/etc C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\files\conf_open5g



```

subir archivos:

```bash
#UPF -1
scp -r -i "pablo-rejo-keys-ec2.pem" "C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\*" ubuntu@51.92.182.86:/home/ubuntu

#UPF -2
scp -r -i "pablo-rejo-keys-ec2.pem" "C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\*" ubuntu@18.100.43.132:/home/ubuntu

# Core
scp -r -i "pablo-rejo-keys-ec2.pem" "C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\*" ubuntu@18.101.142.15:/home/ubuntu

# UEs
scp -r -i "pablo-rejo-keys-ec2.pem" "C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\*" ubuntu@51.94.3.109:/home/ubuntu

# UEs - only sh
scp -r -i "pablo-rejo-keys-ec2.pem" "C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\*.sh" ubuntu@51.94.3.109:/home/ubuntu

# gnB
scp -r -i "pablo-rejo-keys-ec2.pem" "C:\Users\Pablo\Documents\documentos_pablo\MASTER\ENI\Prácticas\Entrega_3\AWS\*" ubuntu@51.92.175.177:/home/ubuntu
```

# Pruebas

Instalar iperf3
```bash
sudo apt-get update && sudo apt-get install -y iperf3
```
