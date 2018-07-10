# Script chuẩn bị Host CentOS 7
---
## Mục đích
- Cấu hình IP
- Cấu hình host, host file
- Cấu hình Firewalld
- Cấu hình SELinux
## Cách sử dụng
> Script cần được chạy bằng user `root`
### Thiết lập File config của script
> File cấu hình mặc định tại: `<project>/src/config/config.yaml`

__Cấu trúc__

```
host:
  hostname: <ten-host>
  ip: <ip-host>

hostfile:
  hosts: a b
  a:
    ip: 123.123.123.123
  b:
    ip: 123.123.45.123

network:
  interface: <list-interface>
  <ten-interface>:  
    ip: <ip-interface>/<netmask-num>
    gateway: <gateway-ip>
    dns: <dns>
  <ten-interface>:
    ....

package:
  lists: <list-package>

root:
  password: <passwd>

VD:

host:
  hostname: cephaio
  ip: 172.16.4.204
  
hostfile:
  hosts: a b
  a:
    ip: 123.123.123.123
  b:
    ip: 123.123.45.123

network:
  interface: ens160 ens192
  ens160:
    ip: 172.16.4.204/24
    gateway: 172.16.10.1
    dns: 8.8.8.8
  ens192:
    ip: 10.0.10.1/24

package:
  lists: vim wget crudini fping sshpass

root:
  password: 123456a@
```

Lưu ý:
- Khai báo đầu đủ các mục host, hostfile, network, root. Thiếu có thể gây lỗi
- Cần có netmark-num sau các ip (như ví dụ)
- Cần liệt kế số interface và mô tả interface. Hỗ trợ các tham số cấu hình ip, gateway, dns
- Cần cung cấp passwd root để thực thi 1 số tính năng

### Chạy Script
Thiết lập quyển thực thi
```
chmod +x <project>/src/install.sh
```

Chạy script
```
bash ./<project>/src/install.sh
```

### Trace log
> Log của script sẽ hiện thị ra màn hình và file log.

LOG FILE BAO GỒM:
- `trace.log`: Log chung của script
- `error.log`: Log error của script
