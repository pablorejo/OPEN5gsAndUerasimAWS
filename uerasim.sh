git clone https://github.com/aligungr/UERANSIM

sudo apt update -y
sudo apt upgrade -y

sudo apt install make -y
sudo apt install gcc -y
sudo apt install g++ -y
sudo apt install libsctp-dev lksctp-tools -y
sudo apt install iproute2 -y
sudo snap install cmake --classic

cd ~/UERANSIM
make