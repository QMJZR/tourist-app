export class Zone {
  zoneId: number = 0;
  name: string = '';
  description: string = '';
  banner: string[] = [];
}

export class ZoneListResponse {
  code: number = 0;
  message: string = '';
  data: Zone[] = [];
}