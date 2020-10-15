#include <sys/types.h>  /* for type definitions */
#include <winsock2.h>   /* for win socket API calls */
#include <ws2tcpip.h>   /* for win socket structs */
#include <stdio.h>      /* for printf() and printf() */
#include <signal.h>
#include <stdlib.h>     /* for atoi() */
#include <string.h>     /* for strlen() */

#include "mex.h"
#include "matrix.h"
#include "UdpClient.h"

#pragma comment(lib,"wsock32.lib")


UdpClient::UdpClient(char *mc_addr_str, unsigned short mc_port, DWORD recvTimeout)
{
    char errorMsg[100];
    
    /* Initialise winsock */
	printf("\nInitialising Winsock...");
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
	{
        mexErrMsgTxt("WSAStartup() failed");
// 		printf("Failed. Error Code : %d", WSAGetLastError());
// 		fgetc(stdin);
// 		exit(EXIT_FAILURE);
	}
	printf("Initialised.\n");

	/* Prepare the sockaddr_in structure for the Server (this computer) */
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons(LOCALPORT);

	/* Create socket */
	if ((s = socket(AF_INET, SOCK_DGRAM, 0)) == INVALID_SOCKET)
	{
        mexErrMsgTxt("Unable to create socket");
        WSACleanup();
// 		printf("Could not create socket : %d", WSAGetLastError());
// 		fgetc(stdin);
// 		exit(EXIT_FAILURE);
	}
	printf("Socket created.\n");

	/* Set socket for broadcast */
	BOOL enabled = TRUE;
	if (setsockopt(s, SOL_SOCKET, SO_BROADCAST, (char*)&enabled, sizeof(BOOL)) < 0)
	{
        closesocket(s);
        WSACleanup();
        mexErrMsgTxt("setsockopt() failed (broadcast options)");
// 		perror("broadcast options");
// 		fgetc(stdin);

// 		return 1;
	}
    
    /* set timeout value */
    if ((setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const char*)&recvTimeout, sizeof(recvTimeout))) < 0) {
        closesocket(s);
        WSACleanup();
        mexErrMsgTxt("setsockopt() failed (timeout)");
    }

	/* Bind socket (for listening)*/
	if (bind(s, (struct sockaddr *) &server, sizeof(server)) == SOCKET_ERROR)
	{
        closesocket(s);
        WSACleanup();
        
        sprintf(errorMsg, "Unable to bind socket, error code: %d", WSAGetLastError());
        mexErrMsgTxt(errorMsg);
// 		printf("Bind failed with error code : %d", WSAGetLastError());
// 		fgetc(stdin);
// 		exit(EXIT_FAILURE);
	}
// 	puts("Bind done");

	// Now prepare broadcast info 
	client.sin_family = AF_INET;
	client.sin_port = htons(REMOTEPORT);
	client.sin_addr.s_addr = inet_addr("255.255.255.255");
//     client.sin_addr.s_addr = inet_pton("255.255.255.255");
	/* Create packet */
	// [uint8(1) uint8(23) typecast(uint16(localPort), 'uint8')]
	unsigned char bCstMsg[] = { 1, 23, 0, 0 };
	bCstMsg[3] = (LOCALPORT >> 8) & 0xff;
	bCstMsg[2] = LOCALPORT & 0xff;
	sendto(s, (char *) bCstMsg, sizeof(bCstMsg), 0, (sockaddr *) &client, sizeof(struct sockaddr_storage));
	printf("\nBroadcast packet sent (%x, %x, %x, %x)", bCstMsg[0], bCstMsg[1], bCstMsg[2], bCstMsg[3]);

	/* Try to receive the reply packet (client will be overwritten with client IP and port) */
	slen = sizeof(client);
	if ((receivedLen = recvfrom(s, buf, BUFLEN, 0, (struct sockaddr *) &client, &slen)) == SOCKET_ERROR)
	{
        sprintf(errorMsg, "recvfrom() failed, error code: %d", WSAGetLastError());
        closesocket(s);
        WSACleanup();
        mexErrMsgTxt(errorMsg);
// 		printf("recvfrom() failed with error code : %d", WSAGetLastError());
// 		fgetc(stdin);
// 		exit(EXIT_FAILURE);
	}
    printf("Success!");
    
//     flag_on = 1;
//     
//     /* Load Winsock 2.0 DLL */
//     if (WSAStartup(MAKEWORD(2, 0), &wsaData) != 0) {
//         mexErrMsgTxt("WSAStartup() failed");
//     }
//     
//     /* create socket to join multicast group on */
//     if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
//         mexErrMsgTxt("socket() failed");
//     }
//     
//     /* set reuse port to on to allow multiple binds per host */
//     if ((setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*)&flag_on, sizeof(flag_on))) < 0) {
//         mexErrMsgTxt("setsockopt() failed");
//     }
//     
//     /* set timeout value */
//     if ((setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&recvTimeout, sizeof(recvTimeout))) < 0) {
//         mexErrMsgTxt("setsockopt() failed");
//     }
//     
//     /* construct a multicast address structure */
//     memset(&mc_addr, 0, sizeof(mc_addr));
//     mc_addr.sin_family      = AF_INET;
//     mc_addr.sin_addr.s_addr = htonl(INADDR_ANY);
//     mc_addr.sin_port        = htons(mc_port);
//     
//     /* bind to multicast address to socket */
//     if ((bind(sock, (struct sockaddr *) &mc_addr, sizeof(mc_addr))) < 0) {
//         mexErrMsgTxt("bind() failed");
//     }
//     
//     /* construct an IGMP join request structure */
//     mc_req.imr_multiaddr.s_addr = inet_addr(mc_addr_str);
//     mc_req.imr_interface.s_addr = htonl(INADDR_ANY);
//     
//     /* send an ADD MEMBERSHIP message via setsockopt */
//     if ((setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*) &mc_req, sizeof(mc_req))) < 0) {
//         mexErrMsgTxt("setsockopt() failed");
//     }
}

/* Close connection and cleanup */
UdpClient::~UdpClient()
{
      /* send a DROP MEMBERSHIP message via setsockopt */
//     if ((setsockopt(sock, IPPROTO_IP, IP_DROP_MEMBERSHIP, (char*) &mc_req, sizeof(mc_req))) < 0) {
//         mexErrMsgTxt("setsockopt() failed");
//     }
    
    closesocket(s);
    WSACleanup();  /* Cleanup Winsock */
//     /* send a DROP MEMBERSHIP message via setsockopt */
//     if ((setsockopt(sock, IPPROTO_IP, IP_DROP_MEMBERSHIP, (char*) &mc_req, sizeof(mc_req))) < 0) {
//         mexErrMsgTxt("setsockopt() failed");
//     }
//     
//     closesocket(sock);
//     WSACleanup();  /* Cleanup Winsock */
}

/* Wait for received packet */
void UdpClient::receivePacket(mxArray **out)
{
    /* create a single element return for now */
    *out = mxCreateNumericMatrix(MAX_LEN,1,mxUINT8_CLASS,mxREAL);
    
    /* clear the receive buffers & structs */
    memset(recv_str, 0, sizeof(recv_str));
    from_len = sizeof(from_addr);
    memset(&from_addr, 0, from_len);
    
    /* timeout based waiting to receive a packet */
    recv_len = recvfrom(s, recv_str, MAX_LEN, 0, (struct sockaddr*) &client, &slen);
    
    /* output received string */
    if (recv_len>0) {
        mxSetM(*out,recv_len);
        recv_bytes = (char*)mxGetPr(*out);
        memcpy(recv_bytes,recv_str,sizeof(char)*recv_len);
        
        // printf("Received %d bytes from %s: ", recv_len, inet_ntoa(from_addr.sin_addr));
        // for (int ii=0; ii<recv_len; ii++)
        //     printf("%c", recv_str[ii]);
        // printf("\n");
    }
    else
    {
        mxSetM(*out, 0);
    }
}

/* Send packet, returns 0 on failure, */
void UdpClient::sendPacket(const char *packet, unsigned int numBytes, mxArray **out) {
    *out = mxCreateNumericMatrix(1,1,mxUINT8_CLASS,mxREAL);
    if (sendto(s, packet, numBytes, 0, (struct sockaddr*) &client, slen) == SOCKET_ERROR)
    {
        printf("sendto() failed with error code : %d", WSAGetLastError());
        mxSetM(*out, 0);
    }
    else {
        mxSetM(*out, 1);
        recv_bytes = (char *) mxGetPr(*out);
        memcpy(recv_bytes, &numBytes, sizeof(numBytes));
    }
}