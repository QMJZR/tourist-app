package com.group9.harmonyapp.po;

//import com.group9.harmonyapp.vo.UserVO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class User {

    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    @Column(name = "id")
    private Long id;

//    @Basic
//    @Column(name = "user_name")
//    private String username;
//
//    @Basic
//    @Column(name = "name")
//    private String name;
//
//    @Basic
//    @Column(name = "avatar")
//    private String avatar;
//    @Basic
//    @Column(name="role")
//    private RoleEnum role;
//    @Basic
//    @Column(name = "telephone")
//    private String telephone;

    @Basic
    @Column(name = "password")
    private String password;
//    @Basic
//    @Column(name = "create_time")
//    private Date createTime;
//
//    @Basic
//    @Column(name = "location")
//    private String location;
//    @Basic
//    @Column(name = "email")
//    private String email;
//    public UserVO toVO(){
//        UserVO userVO=new UserVO();
//        userVO.setId(this.id);
//        userVO.setLocation(this.location);
//        userVO.setName(this.name);
//        userVO.setAvatar(this.avatar);
//        userVO.setRole(this.role);
//        userVO.setTelephone(this.telephone);
//        userVO.setPassword(this.password);
//        userVO.setCreateTime(this.createTime);
//        userVO.setEmail(this.email);
//        userVO.setRole(this.role);
//        userVO.setUsername(this.username);
//        return userVO;
//    }
}
