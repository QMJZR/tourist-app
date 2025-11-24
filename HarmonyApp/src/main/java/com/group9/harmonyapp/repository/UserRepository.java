package com.group9.harmonyapp.repository;
import com.group9.harmonyapp.po.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
//    User findByUsername(String userName);
//    User findByTelephone(String phone);
}
