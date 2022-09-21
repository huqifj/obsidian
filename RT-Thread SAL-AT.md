# RT-Thread SAL-AT


## 网络设备定义

**网络设备**数据结构，其中 `sal_user_data` 指向 `sal_proto_family` 类型变量

- `struct netdev`
    
    ```c
    /* network interface device object */
    struct netdev
    {
        rt_slist_t list; 
        
        char name[RT_NAME_MAX];                            /* network interface device name */
        ip_addr_t ip_addr;                                 /* IP address */
        ip_addr_t netmask;                                 /* subnet mask */
        ip_addr_t gw;                                      /* gateway */
    #if NETDEV_IPV6
        ip_addr_t ip6_addr[NETDEV_IPV6_NUM_ADDRESSES];     /* array of IPv6 addresses */
    #endif /* NETDEV_IPV6 */
        ip_addr_t dns_servers[NETDEV_DNS_SERVERS_NUM];     /* DNS server */
        uint8_t hwaddr_len;                                /* hardware address length */
        uint8_t hwaddr[NETDEV_HWADDR_MAX_LEN];             /* hardware address */
        
        uint16_t flags;                                    /* network interface device status flag */
        uint16_t mtu;                                      /* maximum transfer unit (in bytes) */
        const struct netdev_ops *ops;                      /* network interface device operations */
        
        netdev_callback_fn status_callback;                /* network interface device flags change callback */
        netdev_callback_fn addr_callback;                  /* network interface device address information change callback */
    
    #ifdef RT_USING_SAL
        void *sal_user_data;                               /* user-specific data for SAL */
    #endif /* RT_USING_SAL */
        void *user_data;                                   /* user-specific data */
    };
    ```
    
- `sal_proto_family` **套接字抽象层协议簇**数据结构：
    
    ```c
    struct sal_proto_family
    {
        int family;                                  /* primary protocol families type */
        int sec_family;                              /* secondary protocol families type */
        const struct sal_socket_ops *skt_ops;        /* socket opreations */
        const struct sal_netdb_ops *netdb_ops;       /* network database opreations */
    };
    ```
    
- SAL Socket 操作函数定义
    
    rt-thread\components\net\sal_socket\include\socket\sys_socket\sys\socket.h
    
    ```c
    #define accept(s, addr, addrlen)                           sal_accept(s, addr, addrlen)
    #define bind(s, name, namelen)                             sal_bind(s, name, namelen)
    #define shutdown(s, how)                                   sal_shutdown(s, how)
    #define getpeername(s, name, namelen)                      sal_getpeername(s, name, namelen)
    #define getsockname(s, name, namelen)                      sal_getsockname(s, name, namelen)
    #define getsockopt(s, level, optname, optval, optlen)      sal_getsockopt(s, level, optname, optval, optlen)
    #define setsockopt(s, level, optname, optval, optlen)      sal_setsockopt(s, level, optname, optval, optlen)
    #define connect(s, name, namelen)                          sal_connect(s, name, namelen)
    #define listen(s, backlog)                                 sal_listen(s, backlog)
    #define recv(s, mem, len, flags)                           sal_recvfrom(s, mem, len, flags, NULL, NULL)
    #define recvfrom(s, mem, len, flags, from, fromlen)        sal_recvfrom(s, mem, len, flags, from, fromlen)
    #define send(s, dataptr, size, flags)                      sal_sendto(s, dataptr, size, flags, NULL, NULL)
    #define sendto(s, dataptr, size, flags, to, tolen)         sal_sendto(s, dataptr, size, flags, to, tolen)
    #define socket(domain, type, protocol)                     sal_socket(domain, type, protocol)
    #define closesocket(s)                                     sal_closesocket(s)
    #define ioctlsocket(s, cmd, arg)                           sal_ioctlsocket(s, cmd, arg)
    ```
    

## SAL 初始化

```c
#define SOCKET_TABLE_STEP_LEN          4
#define SAL_SOCKETS_NUM 16

static struct sal_socket_table socket_table;
static struct sal_netdev_res_table sal_dev_res_tbl[SAL_SOCKETS_NUM];
```

```c
int sal_init(void)
{
    int cn;

    if (init_ok)
    {
        LOG_D("Socket Abstraction Layer is already initialized.");
        return 0;
    }

    /* init sal socket table */
    cn = SOCKET_TABLE_STEP_LEN < SAL_SOCKETS_NUM ? SOCKET_TABLE_STEP_LEN : SAL_SOCKETS_NUM;
    socket_table.max_socket = cn;
    socket_table.sockets = rt_calloc(1, cn * sizeof(struct sal_socket *));
    if (socket_table.sockets == RT_NULL)
    {
        LOG_E("No memory for socket table.\n");
        return -1;
    }

    /*init the dev_res table */
    rt_memset(sal_dev_res_tbl,  0, sizeof(sal_dev_res_tbl));

    /* create sal socket lock */
    rt_mutex_init(&sal_core_lock, "sal_lock", RT_IPC_FLAG_FIFO);

    LOG_I("Socket Abstraction Layer initialize success.");
    init_ok = RT_TRUE;

    return 0;
}
INIT_COMPONENT_EXPORT(sal_init);
```

## 网络设备初始化流程

1. 在 `ec200x_netdev_add()` 函数中中申请网络设备空间。
    
    ```c
    netdev = (struct netdev *)rt_calloc(1, sizeof(struct netdev));
    ```
    
2. 设置网络设备 **MTU、硬件地址长度、操作方法（开、关、设置网络地址、设置 DNS 服务器、设置 DHCP、PING、设置默认网络设备）。**
    
    ```c
    netdev->mtu = ETHERNET_MTU;
    netdev->ops = &ec200x_netdev_ops;
    netdev->hwaddr_len = HWADDR_LEN;
    ```
    
    - `ec200x_netdev_ops;`
        
        ```c
        const struct netdev_ops ec200x_netdev_ops =
        {
            ec200x_netdev_set_up,
            ec200x_netdev_set_down,
        
            RT_NULL,
            ec200x_netdev_set_dns_server,
            RT_NULL,
        
        #ifdef NETDEV_USING_PING
            ec200x_netdev_ping,
        #endif
            RT_NULL,
        };
        ```
        
3. 设置 AT 网络设备的协议家族信息。
    
    ```c
    /* Set AT network interface device protocol family information */
    int sal_at_netdev_set_pf_info(struct netdev *netdev)
    {
        RT_ASSERT(netdev);
    
        netdev->sal_user_data = (void *) &at_inet_family;
        return 0;
    }
    ```
    
    在 `sal_at_netdev_set_pf_info` 中赋值 `sal_user_data` 。
    
    ```c
    static const struct sal_proto_family at_inet_family =
    {
        AF_AT,
        AF_INET,
        &at_socket_ops,
        &at_netdb_ops,
    };
    ```
    
    - `at_socket_ops` 结构体包含 AT Socket 操作方法，如发送、接收等。at_socket_ops 中会调用 ec200x 的相关操作方法。
        
        ```c
        static const struct sal_socket_ops at_socket_ops =
        {
            at_socket,
            at_closesocket,
            at_bind,
            NULL,
            at_connect,
            NULL,
            at_sendto,
            at_recvfrom,
            at_getsockopt,
            at_setsockopt,
            at_shutdown,
            NULL,
            NULL,
            NULL,
        #ifdef SAL_USING_POSIX
            at_poll,
        #endif /* SAL_USING_POSIX */
        };
        ```
        
    - `at_netdb_ops` 结构体包含：
        - `gethostbyname()` 返回对应于给定主机名的包含主机名字和地址信息的 hostent 结构的指针。结构的声明与 gethostbyaddr () 中一致。
        - `gethostbyname_r()` 是 `gethostbyname()` 的可重入版本。
        - `getaddrinfo()` 函数能够处理名字到地址以及服务到端口这两种转换，返回的是一个 sockaddr 结构的链表而不是一个地址清单。
        - 由 `getaddrinfo()` 返回的存储空间，包括 addrinfo 结构、ai_addr 结构和 ai_canonname 字符串，都是用 malloc 动态获取的。这些空间可调用 `freeaddrinfo()` 释放。
        
        ```c
        static const struct sal_netdb_ops at_netdb_ops = 
        {
            at_gethostbyname,
            NULL,
            at_getaddrinfo,
            at_freeaddrinfo,
        };
        ```
        
4. 注册网络设备，设备名为 **ec200x**，在这之后可以用 `netdev_get_by_name()` 等方法来查找并使用网络设备。
    
    ```c
    netdev_register(netdev, netdev_name, RT_NULL);
    ```
    

## `socket()` 调用流程

1. 宏定义
    
    ```c
    #define socket(domain, type, protocol)                     sal_socket(domain, type, protocol)
    ```
    
2. `sal_socket()`
    1. `socket_new()`
        
        查找 `socket_table.sockets` 表，返回第一个未使用的元素下标 Index。`socket_table.sockets` 是一个指向指针的指针，可以理解为数组，每个数组元素是 `struct sal_socket *sockets` 类型的指针。
        
        获取到一个 `socket_table.sockets` 元素之后，设置其 SAL 描述符和 MAGIC_NUMBER。
        
        ```c
        sock = st->sockets[idx];
        sock->socket = idx + SAL_SOCKET_OFFSET;  // SAL 描述符
        sock->magic = SAL_SOCKET_MAGIC;          // MAGIC NUMBER
        sock->netdev = RT_NULL;
        sock->user_data = RT_NULL;
        ```
        
        `socket_new()` 函数最后返回 `socket_table.sockets` 可用元素下标。
        
        ```c
        return idx + SAL_SOCKET_OFFSET;
        ```
        
    2. `sal_get_socket()`
        
        此函数接收一个 `socket_table.sockets` 下标，进行合法性检查后，返回 Socket 管理指针（`struct sal_socket *sockets` 类型）。
        
        ```c
        return st->sockets[socket];
        ```
        
    3. `socket_init()`
        
        接收参数：
        
        - family：网络协议的套接字类型，AF_INET（IPV4）为默认值。
        - type：Socket 类型，SOCK_STREAM = TCP，SOCK_DGRAM = UDP。
        - protocol：传输协议号，通常为 0。
        - res：Socket 对象指针。
        
        设置 Socket 相关参数：
        
        ```c
        sock = *res;
        sock->domain = family;
        sock->type = type;
        sock->protocol = protocol;
        ```
        
        设置 Socket 网络设备指针 `sock->netdev`：
        
        ```c
        // 已设置默认设备
        #define netdev_is_up(netdev) (((netdev)->flags & NETDEV_FLAG_UP) ? (uint8_t)1 : (uint8_t)0)
        pf = (struct sal_proto_family *) netdv_def->sal_user_data;
        if (pf != RT_NULL && pf->skt_ops && (pf->family == family || pf->sec_family == family))
        {
            sock->netdev = netdv_def;
        }
        
        // 未设置默认设备
        netdev = netdev_get_by_family(family);
        sock->netdev = netdv_def;
        ```
        
        `sal_user_data` 指针在 sal_at_netdev_set_pf_info 中被设置：
        
        ```c
        static const struct sal_socket_ops at_socket_ops =
        {
            at_socket,
            at_closesocket,
            at_bind,
            NULL,
            at_connect,
            NULL,
            at_sendto,
            at_recvfrom,
            at_getsockopt,
            at_setsockopt,
            at_shutdown,
            NULL,
            NULL,
            NULL,
        #ifdef SAL_USING_POSIX
            at_poll,
        #endif /* SAL_USING_POSIX */
        };
        
        static const struct sal_netdb_ops at_netdb_ops = 
        {
            at_gethostbyname,
            NULL,
            at_getaddrinfo,
            at_freeaddrinfo,
        };
        
        static const struct sal_proto_family at_inet_family =
        {
            AF_AT,
            AF_INET,
            &at_socket_ops,
            &at_netdb_ops,
        };
        
        netdev->sal_user_data = (void *) &at_inet_family;
        ```
        
    4. `SAL_NETDEV_SOCKETOPS_VALID()`
        
        ```c
        #define SAL_NETDEV_SOCKETOPS_VALID(netdev, pf, ops)                               \
        do {                                                                              \
            (pf) = (struct sal_proto_family *) netdev->sal_user_data;                     \
            if ((pf)->skt_ops->ops == RT_NULL){                                           \
                return -1;                                                                \
            }                                                                             \
        }while(0)                                                                         \
        ```
        
    5. `proto_socket = pf->skt_ops->socket(domain, type, protocol);`
        
        proto_socket 保存 AT Socket 描述符。
        
        - 实际调用了 `at_netdb_ops.at_socket()` 。
            1. 设置 Socket 类型；
            2. 申请 Socket；
            3. 设置接收和 Notice 回调函数；
            4. 返回 AT Socket 描述符（`int`）。
            
            ```c
            int at_socket(int domain, int type, int protocol)
            {
                struct at_socket *sock = RT_NULL;
                enum at_socket_type socket_type;
            
                /* check socket family protocol */
                RT_ASSERT(domain == AF_AT || domain == AF_INET);
            
                switch(type)
                {
                case SOCK_STREAM:
                    socket_type = AT_SOCKET_TCP;
                    break;
            
                case SOCK_DGRAM:
                    socket_type = AT_SOCKET_UDP;
                    break;
            
                default :
                    LOG_E("Don't support socket type (%d)!", type);
                    return -1;
                }
            
                /* allocate and initialize a new AT socket */
                sock = alloc_socket(socket_type);
                if (sock == RT_NULL)
                {
                    return -1;
                }
                sock->type = socket_type;
                sock->state = AT_SOCKET_OPEN;
            
                /* set AT socket receive data callback function */
                sock->ops->at_set_event_cb(AT_SOCKET_EVT_RECV, at_recv_notice_cb);
                sock->ops->at_set_event_cb(AT_SOCKET_EVT_CLOSED, at_closed_notice_cb);
            
                return sock->socket;
            }
            ```
            
            - `alloc_socket()`
                1. 获取网路设备；
                2. 获取设备；
                3. 返回 `alloc_socket_by_device()` 申请的 `struct at_socket *` 类型 Socket。
                
                ```c
                static struct at_socket *alloc_socket(enum at_socket_type type)
                {
                    extern struct netdev *netdev_default;
                    struct netdev *netdev = RT_NULL;
                    struct at_device *device = RT_NULL;
                
                    if (netdev_default && netdev_is_up(netdev_default) &&
                            netdev_family_get(netdev_default) == AF_AT)
                    {
                        netdev = netdev_default;
                    }
                    else
                    {
                        /* get network interface device by protocol family AF_AT */
                        netdev = netdev_get_by_family(AF_AT);
                        if (netdev == RT_NULL)
                        {
                            return RT_NULL;
                        }
                    }
                
                    device = at_device_get_by_name(AT_DEVICE_NAMETYPE_NETDEV, netdev->name);
                    if (device == RT_NULL)
                    {
                        return RT_NULL;
                    }
                
                    return alloc_socket_by_device(device, type);
                }
                ```
                
            - `alloc_socket_by_device()`
                1. 创建互斥量
                    
                    ```c
                    at_slock = rt_mutex_create("at_slock", RT_IPC_FLAG_FIFO);
                    
                    rt_mutex_release(at_slock);
                    ```
                    
                2. 获取一个空 Socket 管理指针下标（`_dev.device.sockets`）
                    
                    ```c
                    // static struct at_device_ec200x _dev;
                    // _dev.device.*sockets;*
                    
                    /* find an empty at socket entry */
                    for (idx = 0; idx < device->class->socket_num && device->sockets[idx].magic; idx++);
                    
                    /* can't find an empty protocol family entry */
                    if (idx < 0 || idx >= device->class->socket_num)
                    {
                        goto __err;
                    }
                    ```
                    
                3. 申请 Socket
                    
                    ```c
                    struct at_socket *sock = RT_NULL;
                    
                    sock = &(device->sockets[idx]);
                    /* the socket descriptor is the number of sockte lists */
                    sock->socket = alloc_empty_socket(&(sock->list));
                    ```
                    
                4. 设置 Socket 参数
                    
                    ```c
                    /* the socket operations is the specify operations of the device */
                    sock->ops = device->class->socket_ops;
                    /* the user-data is the at device socket descriptor */
                    sock->user_data = (void *) idx;
                    sock->device = (void *) device;
                    sock->magic = AT_SOCKET_MAGIC;
                    sock->state = AT_SOCKET_NONE;
                    sock->rcvevent = RT_NULL;
                    sock->sendevent = RT_NULL;
                    sock->errevent = RT_NULL;
                    rt_slist_init(&sock->recvpkt_list);
                    ```
                    
                5. 创建接收信号量
                    
                    ```c
                    rt_snprintf(name, RT_NAME_MAX, "%s%d", "at_skt", idx);
                    /* create AT socket receive mailbox */
                    if ((sock->recv_notice = rt_sem_create(name, 0, RT_IPC_FLAG_FIFO)) == RT_NULL)
                    {
                        LOG_E("No memory socket receive notic semaphore create.");
                        goto __err;
                    }
                    ```
                    
                6. 创建接收互斥量，用于环形缓冲区保护
                    
                    ```c
                    rt_snprintf(name, RT_NAME_MAX, "%s%d", "at_skt", idx);
                    /* create AT socket receive ring buffer lock */
                    if((sock->recv_lock = rt_mutex_create(name, RT_IPC_FLAG_FIFO)) == RT_NULL)
                    {
                        LOG_E("No memory for socket receive mutex create.");
                        rt_sem_delete(sock->recv_notice);
                        goto __err;
                    }
                    ```
                    
                7. 返回 `struct at_socket *` 类型 Socket
                    
                    ```c
                    return sock;
                    ```
                    
    6. `sock->user_data = (void *) proto_socket;`
        
        保存 AT Socket 描述符。
        
    7. `return sock->socket;`
        
        返回 SAL Socket 描述符，即在 `socket_new()` 中赋值的 `sock->socket = idx + SAL_SOCKET_OFFSET;`，`int` 类型。
        

## `connect()` 调用流程

宏定义在头文件 rt-thread\components\net\sal_socket\include\socket\sys_socket\sys\socket.h

```c
#define connect(s, name, namelen)                          sal_connect(s, name, namelen)
```

- `sal_connect()`
    1. 通过 SAL Socket 描述符查找 SAL Socket（`struct sal_socket *sock`）
        
        ```c
        /* get the socket object by socket descriptor */
        SAL_SOCKET_OBJ_GET(sock, socket);
        
        #define SAL_SOCKET_OBJ_GET(sock, socket)                                          \
        do {                                                                              \
            (sock) = sal_get_socket(socket);                                              \
            if ((sock) == RT_NULL) {                                                      \
                return -1;                                                                \
            }                                                                             \
        } while(0)                                                                         \
        ```
        
    2. 检查网络设备是否就绪
        
        ```c
        /* check the network interface is up status */
        SAL_NETDEV_IS_UP(sock->netdev);
        
        #define SAL_NETDEV_IS_UP(netdev)                                                  \
        do {                                                                              \
            if (!netdev_is_up(netdev)) {                                                  \
                return -1;                                                                \
            }                                                                             \
        } while(0)                                                                         \
        ```
        
    3. 检查网络设备 Socket 操作方法是否被设置
        
        ```c
        /* check the network interface socket opreation */
        SAL_NETDEV_SOCKETOPS_VALID(sock->netdev, pf, connect);
        
        #define SAL_NETDEV_SOCKETOPS_VALID(netdev, pf, ops)                               \
        do {                                                                              \
            (pf) = (struct sal_proto_family *) netdev->sal_user_data;                     \
            if ((pf)->skt_ops->ops == RT_NULL){                                           \
                return -1;                                                                \
            }                                                                             \
        } while(0)                                                                         \
        ```
        
    4. 调用网络设备的 Socket 操作方法 `connect()`
        
        ```c
        ret = pf->skt_ops->connect((int) sock->user_data, name, namelen);
        ```
        
    5. 返回 `int` 类型结果。
        
        ```c
        return ret;
        ```
        
    
- `pf->skt_ops->connect((int) sock->user_data, name, namelen)`
    - 关键变量解释
        - `sock`，`struct sal_socket *` 类型指针，用于管理指定 SAL Descriptor 的 SAL Socket。
        - `sock->netdev`，`struct netdev *` 类型指针，指向 `ec200x_netdev_add()` 中创建的网络设备。其中 `netdev->ops = &ec200x_netdev_ops;`。
        - `sock->user_data` ，`void *` 类型指针，指针的值是 AT Socket Descriptor。其值在创建 SAL Socket 被设置。
            
            ```c
            proto_socket = pf->skt_ops->socket(domain, type, protocol);
            sock->user_data = (void *) proto_socket;
            ```
            
        - `pf`，`struct sal_proto_family *` 类型指针，指向 `at_inet_family` 结构体。
            
            ```c
            // rt-thread\components\net\sal_socket\src\sal_socket.c
            (pf) = (struct sal_proto_family *) netdev->sal_user_data;
            
            // rt-thread\components\net\sal_socket\impl\af_inet_at.c
            netdev->sal_user_data = (void *) &at_inet_family;
            ```
            
        - `pf->skt_ops->connect`，实际上调用 `at_socket_ops.at_connect()` 。
    - `at_socket_ops.at_connect()`
        
        签名：
        
        ```c
        // socket：AT Socket Descriptor
        // name：包含网络类型、IP、PORT（struct sockaddr_in 结构体指针强转 struct sockaddr *）
        // namelen：sizeof(sizeof(struct sockaddr))
        // return：0 成功，others 失败
        int at_connect(int socket, const struct sockaddr *name, socklen_t namelen);
        ```
        
        获取 AT Socket：
        
        ```c
        struct at_socket *sock = RT_NULL;
        sock = at_get_socket(socket);
        ```
        
        检查 Socket 是否已打开：
        
        ```c
        if (sock->state != AT_SOCKET_OPEN)
        {
            LOG_E("Socket(%d) connect state is %d.", sock->socket, sock->state);
            result = -1;
            goto __exit;
        }
        ```
        
        调用操作函数建立连接：
        
        ```c
        if (sock->ops->at_connect(sock, ipstr, remote_port, sock->type, RT_TRUE) < 0)
        {
            result = -1;
            goto __exit;
        }
        ```
        
        设置 AT Socket 状态：
        
        ```c
        sock->state = AT_SOCKET_CONNECT;
        ```
        
        设置发送计次？（存疑）
        
        ```c
        at_do_event_changes(sock, AT_EVENT_SEND, RT_TRUE);
        ```
        
    - `sock->ops->at_connect()`
        
        实际调用 `ec200x_socket_ops.ec200x_socket_connect()` 函数：
        
        ```c
        // socket：AT Socket
        // ip：
        // port：
        // type：AT_SOCKET_TCP/AT_SOCKET_UDP
        // is_client：是否 Client（目前只指针 Client）
        static int ec200x_socket_connect(struct at_socket *socket, char *ip, int32_t port,
            enum at_socket_type type, rt_bool_t is_client);
        ```