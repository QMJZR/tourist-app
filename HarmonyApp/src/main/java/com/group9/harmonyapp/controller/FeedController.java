package com.group9.harmonyapp.controller;
import com.group9.harmonyapp.dto.*;
import com.group9.harmonyapp.service.FeedLikeService;
import com.group9.harmonyapp.service.FeedService;
import com.group9.harmonyapp.util.TokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/V1/feeds")
@RequiredArgsConstructor
public class FeedController {

    private final FeedService feedService;
    private final FeedLikeService likeService;
    private final TokenUtil tokenUtil;

    @GetMapping("")
    public Response<PageResponseDTO<FeedResponseDTO>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String keyword,
            @RequestHeader("Authorization") String auth
    ) {
        String token = auth.substring(7);
        Long loginUser = tokenUtil.getUser(token).getId();

        PageResponseDTO<FeedResponseDTO> data =
                feedService.list(loginUser, userId, keyword, sort, page, pageSize);

        return Response.buildSuccess(data);
    }


    @PostMapping("/{id}/like")
    public Response<FeedLikeDTO> like(@PathVariable Long id, @RequestHeader("Authorization") String auth) {
        String token = auth.substring(7);
        Long user = tokenUtil.getUser(token).getId();
        return Response.buildSuccess(likeService.like(id, user), "点赞成功");
    }


    @DeleteMapping("/{id}/like")
    public Response<FeedLikeDTO> unlike(@PathVariable Long id,  @RequestHeader("Authorization") String auth) {
        String token = auth.substring(7);
        Long user = tokenUtil.getUser(token).getId();
        return Response.buildSuccess(likeService.unlike(id, user), "取消点赞成功");
    }
}