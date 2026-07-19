export interface WebRTCConfig {
  iceServers?: RTCIceServer[];
}

export interface RoomOptions {
  roomId: string;
  userId: string;
}

export interface PeerConnection {
  id: string;
  connection: RTCPeerConnection;
  stream?: MediaStream;
}

export class WebRTCManager {
  private config: WebRTCConfig;
  private peerConnections: Map<string, PeerConnection> = new Map();
  private localStream?: MediaStream;
  private roomId: string;
  private userId: string;

  constructor(options: RoomOptions, config?: WebRTCConfig) {
    this.roomId = options.roomId;
    this.userId = options.userId;
    this.config = config || {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
      ],
    };
  }

  async join(): Promise<void> {
    console.log(`Joining room ${this.roomId} as user ${this.userId}`);
  }

  async leave(): Promise<void> {
    this.localStream?.getTracks().forEach(track => track.stop());
    this.peerConnections.forEach(pc => pc.connection.close());
    this.peerConnections.clear();
    console.log(`Left room ${this.roomId}`);
  }

  async getLocalStream(): Promise<MediaStream> {
    this.localStream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true,
    });
    return this.localStream;
  }

  async createPeerConnection(peerId: string): Promise<RTCPeerConnection> {
    const connection = new RTCPeerConnection(this.config);
    
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => {
        connection.addTrack(track, this.localStream!);
      });
    }

    connection.onicecandidate = (event) => {
      if (event.candidate) {
        console.log('ICE candidate:', event.candidate);
      }
    };

    connection.ontrack = (event) => {
      console.log('Remote track:', event.streams[0]);
    };

    this.peerConnections.set(peerId, { id: peerId, connection });
    return connection;
  }

  async createOffer(peerId: string): Promise<RTCSessionDescriptionInit> {
    const pc = this.peerConnections.get(peerId);
    if (!pc) throw new Error('Peer connection not found');

    const offer = await pc.connection.createOffer();
    await pc.connection.setLocalDescription(offer);
    return offer;
  }

  async createAnswer(peerId: string, offer: RTCSessionDescriptionInit): Promise<RTCSessionDescriptionInit> {
    const pc = this.peerConnections.get(peerId);
    if (!pc) throw new Error('Peer connection not found');

    await pc.connection.setRemoteDescription(offer);
    const answer = await pc.connection.createAnswer();
    await pc.connection.setLocalDescription(answer);
    return answer;
  }

  async handleAnswer(peerId: string, answer: RTCSessionDescriptionInit): Promise<void> {
    const pc = this.peerConnections.get(peerId);
    if (!pc) throw new Error('Peer connection not found');

    await pc.connection.setRemoteDescription(answer);
  }

  getPeerConnection(peerId: string): PeerConnection | undefined {
    return this.peerConnections.get(peerId);
  }
}
