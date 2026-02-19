// java
package com.example.backend.services;

import com.example.backend.entity.Member;
import com.example.backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;
    private final MemberRepository memberRepository;

    @Value("${spring.mail.properties.mail.smtp.from:no-reply@yourdomain.com}")
    private String defaultFrom;

    public void sendOtp(String to, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(defaultFrom);
        message.setTo(to);
        message.setSubject("WelfareNet One-Time_Password (OTP)");
        message.setText("Dear Valued Member,\n\n"+
                "Your OTP (One Time Password) is: "+ otp +" for reset password in WelfareNet.\n"+
                "Please note: OTP is valid only for 2 minutes. DO NOT share this OTP with any third party.\n\n"+
                "Best Regards,\n" +
                "Technical Team\n"+
                "WelfareNet");
        try {
            mailSender.send(message);
        } catch (MailException ex) {
            // log and rethrow or handle according to app policy
            System.err.println("Failed to send email to " + to + ": " + ex.getMessage());
            throw ex;
        }
    }

    @Async
    public void sendEmailAsync(Integer memberId, String subject, String message) {

        Member member = memberRepository.findById(memberId).orElse(null);
        if (member == null) {
            return;
        }

        SimpleMailMessage mail = new SimpleMailMessage();
        mail.setTo(member.getEmail());
        mail.setSubject(subject);
        mail.setText(message);

        mailSender.send(mail);
    }

    @Async
    public void sendMail(String to, String subject, String message) {

        SimpleMailMessage mail = new SimpleMailMessage();
        mail.setFrom(defaultFrom);
        mail.setTo(to);
        mail.setSubject(subject);
        mail.setText(message);

        try {
            mailSender.send(mail);
        } catch (MailException ex) {
            System.err.println("Failed to send email to " + to + ": " + ex.getMessage());
            throw ex;
        }
    }

}

