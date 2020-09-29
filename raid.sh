yum install -y mdadm parted;
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g};
mdadm --create --verbose /dev/md/raid10 -l 10 -n 4 -x 1 /dev/sd{b,c,d,e,f};
mkdir -p /etc/mdadm;
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf;
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

parted -s /dev/md/raid10 mklabel gpt;
parted /dev/md/raid10 mkpart primary ext4 0% 20%;
parted /dev/md/raid10 mkpart primary ext4 20% 40%;
parted /dev/md/raid10 mkpart primary ext4 40% 60%;
parted /dev/md/raid10 mkpart primary ext4 60% 80%;
parted /dev/md/raid10 mkpart primary ext4 80% 100%;

for i in $(seq 1 5); do mkfs.ext4 /dev/md127p$i; done;

mkdir -p /mnt/raid/part{1,2,3,4,5};
for i in $(seq 1 5); do mount /dev/md127p$i /mnt/raid/part$i; done;

mdadm --fail /dev/md/raid10 /dev/sdb;
mdadm --remove /dev/md/raid10 /dev/sdb;
mdadm --add /dev/md/raid10 /dev/sdg;
