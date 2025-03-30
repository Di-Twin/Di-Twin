"use client"
import Link from "next/link";
import { LogIn } from 'lucide-react';
import { useState, useEffect } from "react";

const HeroSection = () => {
  const [text, setText] = useState("");
  const [isTyping, setIsTyping] = useState(true);
  
  const fullText = "Experience Smarter Healthcare with DTwin";
  
  useEffect(() => {
    if (isTyping && text.length < fullText.length) {
      const timeout = setTimeout(() => {
        setText(fullText.slice(0, text.length + 1));
      }, 100); // Adjust speed here (lower = faster)
      
      return () => clearTimeout(timeout);
    } else if (text.length === fullText.length) {
      setIsTyping(false);
    }
  }, [text, isTyping, fullText]);

  return (
    <>
      <div
        className="zubuz-hero-section white-bg"
        style={{ backgroundImage: "url(/images/v1/hero-shape1.png)" }}
        id="home"
      >
        <div className="container">
          <div className="zubuz-hero-content center position-relative">
            <h1 className="hero-text-xl">
              {text}
              <span className={isTyping ? "typing-cursor" : "typing-cursor hidden"}>|</span>
            </h1>
            <p>
              Our AI-powered platform helps you take control of your health with
              predictive analysis, real-time monitoring, and personalized
              wellness strategies, ensuring a healthier future with data-driven
              decisions.
            </p>
            <div className="zubuz-hero-btn-wrap center">
              {/* <Link className="zubuz-hero-video" href="contact-us">
                <span>Start Your Free Trial</span>
              </Link> */}
              <a
                href="https://forms.gle/WFqdwC331ZSSWLLG6"
                target="_blank"
                rel="noopener noreferrer"
                className="zubuz-default-btn"
              >
                <span><LogIn className="mr-2" size={20} /> <img src="" alt="" /> Join the Beta Program</span>
              </a>
            </div>
            <div className="zubuz-hero-shape">
              <img src="/images/v1/shape.png" alt="" />
            </div>
          </div>
          <div className="zubuz-hero-bottom">
            <div className="zubuz-hero-thumb wow fadeInUpX">
              <img src="/images/v1/hero-mocup1.png" alt="" />
            </div>
            <div className="zubuz-hero-card card1 wow zoomIn">
              <img src="/images/v1/h-card1.png" alt="" />
            </div>
            <div className="zubuz-hero-card card2 wow zoomIn">
              <img src="/images/v1/h-card2.png" alt="" />
            </div>
            <div className="zubuz-hero-card card3 wow zoomIn">
              <img src="/images/v1/h-card4.png" alt="" />
            </div>
            <div className="zubuz-hero-card card4 wow zoomIn">
              <img src="/images/v1/h-card3.png" alt="" />
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default HeroSection;