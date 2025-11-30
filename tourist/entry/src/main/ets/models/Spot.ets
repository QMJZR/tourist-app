export class Spot {
  spotId: number = 0;
  name: string = '';
  thumbnail: string = '';
  summary: string = '';
  zoneId: number = 0;
  distance: number = 0;
}

export class SpotDetail {
  spotId: number = 0;
  name: string = '';
  images: string[] = [];
  video: string = '';
  description: string = '';
  zoneId: number = 0;
  latitude: number = 0;
  longitude: number = 0;
  openTime: string = '';
}

export class SpotListData {
  list: Spot[] = [];
  page: number = 1;
  pageSize: number = 10;
  total: number = 0;
}

export class SpotListResponse {
  code: number = 0;
  message: string = '';
  data?: SpotListData;
}

export class SpotDetailResponse {
  code: number = 0;
  message: string = '';
  data?: SpotDetail;
}