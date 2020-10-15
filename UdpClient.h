#ifndef UDP_CLIENT_H_
#define UDP_CLIENT_H_

#include <sys/types.h>      /* for type definitions */
#include <winsock2.h>       /* for win socket API calls */
#include <ws2tcpip.h>       /* for win socket structs */

#define BUFLEN 128          /* Max length of buffer */
#define MAX_LEN  1024       /* maximum receive string size */
#define MIN_PORT 1024       /* minimum port allowed */
#define MAX_PORT 65535      /* maximum port allowed */
#define REMOTEPORT	57185   /* Port client will be listening on */
#define LOCALPORT	59000   /* Server listening port */

class UdpClient {
private:
    SOCKET s;
	struct sockaddr_in server, client;
	int slen, recv_len, receivedLen;
	char buf[BUFLEN];
	WSADATA wsa;
	char string[50];
    
    // Original variables
    char recv_str[MAX_LEN+1];
    int from_len;
    struct sockaddr_in from_addr;
    char *recv_bytes;
//     int sock;                     /* socket descriptor */
//     int flag_on;                  /* socket option flag */
//     struct sockaddr_in mc_addr;   /* socket address structure */
//     char recv_str[MAX_LEN+1];     /* buffer to receive string */
//     char *recv_bytes;
//     int recv_len;                 /* length of string received */
//     struct ip_mreq mc_req;        /* multicast request structure */
//     struct sockaddr_in from_addr; /* packet source */
//     //unsigned int from_len;      /* source addr length */
//     int from_len;                 /* source addr length */
//     WSADATA wsaData;              /* Windows socket DLL structure */
    
public:
    /* Open UDP socket connection */
    UdpClient(char *mc_addr_str, unsigned short mc_port, DWORD recvTimeout);
    
    /* Close connection and cleanup */
    ~UdpClient();
    
    /* Wait for received packet */
    void receivePacket(mxArray **out);
    
    /* Send packet */
    void UdpClient::sendPacket(const char *packet, unsigned int numBytes, mxArray **out);
};

#endif