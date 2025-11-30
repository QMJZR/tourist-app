export class BaseResponse<T = object> {
  code: number = 0;
  message: string = '';
  data?: T;
}

export class PageParams {
  page: number = 1;
  pageSize: number = 10;
}

export class ListResponse<T> {
  list: T[] = [];
  page: number = 1;
  pageSize: number = 10;
  total: number = 0;
}

export class EmptyData {}