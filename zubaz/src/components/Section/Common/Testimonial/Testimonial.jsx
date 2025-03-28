/* eslint-disable react/no-unescaped-entities */
"use client";
import Link from "next/link";
import { useState } from "react";
import { ArrowRight, Sparkles, Zap, BarChart2 } from 'lucide-react';

const BetaProgramBanner = () => {
  const [email, setEmail] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    // Here you would handle the form submission, like redirecting to the Google Form
    window.open("https://forms.gle/WFqdwC331ZSSWLLG6", "_blank");
  };

  return (
    <div className="section zubuz-section-padding2 light-bg">
      <div className="container">
        <div className="beta-program-banner">
          <div className="beta-program-content">
            <div className="beta-badge">
              <Sparkles className="sparkle-icon" size={16} />
              <span>Limited Access</span>
            </div>
            
            <h2 className="beta-title">Join Our Exclusive Beta Program</h2>
            
            <p className="beta-description">
              Be among the first to experience our revolutionary health platform. 
              Get early access to premium features and help shape the future of digital healthcare.
            </p>
            
            <div className="beta-features">
              <div className="beta-feature">
                <div className="feature-icon">
                  <Zap size={20} />
                </div>
                <div className="feature-text">
                  <h4>Early Access</h4>
                  <p>Get first access to all premium features</p>
                </div>
              </div>
              
              <div className="beta-feature">
                <div className="feature-icon">
                  <BarChart2 size={20} />
                </div>
                <div className="feature-text">
                  <h4>Personalized Insights</h4>
                  <p>Receive customized health analytics</p>
                </div>
              </div>
            </div>
            
            <form onSubmit={handleSubmit} className="beta-form">
              <input 
                type="email" 
                placeholder="Enter your email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <button type="submit" className="zubuz-default-btn">
                <span>Join Beta Program</span>
                <ArrowRight size={16} className="ml-2" />
              </button>
            </form>
            
            <p className="beta-note">
              Limited spots available. No credit card required.
            </p>
          </div>
          
          <div className="beta-program-image">
            <div className="image-container">
              <img src="/images/v1/beta-program.png" alt="DTwin Beta Program" />
              <div className="floating-badge badge-1">
                <span>20+ Device Integrations</span>
              </div>
              <div className="floating-badge badge-2">
                <span>AI-Powered Insights</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        .beta-program-banner {
          display: flex;
          flex-direction: column;
          gap: 40px;
          background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
          border-radius: 20px;
          overflow: hidden;
          padding: 40px;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
          position: relative;
        }

        @media (min-width: 992px) {
          .beta-program-banner {
            flex-direction: row;
            align-items: center;
          }
        }

        .beta-program-content {
          flex: 1;
          z-index: 2;
        }

        .beta-badge {
          display: inline-flex;
          align-items: center;
          background: linear-gradient(135deg, #4158D0 0%, #C850C0 100%);
          color: white;
          padding: 8px 16px;
          border-radius: 30px;
          margin-bottom: 20px;
          font-weight: 600;
          font-size: 14px;
        }

        .sparkle-icon {
          margin-right: 8px;
        }

        .beta-title {
          font-size: 2.5rem;
          font-weight: 700;
          margin-bottom: 20px;
          background: linear-gradient(135deg, #1a1a1a 0%, #4158D0 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          line-height: 1.2;
        }

        .beta-description {
          font-size: 1.1rem;
          color: #555;
          margin-bottom: 30px;
          max-width: 600px;
        }

        .beta-features {
          display: flex;
          flex-direction: column;
          gap: 20px;
          margin-bottom: 30px;
        }

        @media (min-width: 768px) {
          .beta-features {
            flex-direction: row;
            gap: 40px;
          }
        }

        .beta-feature {
          display: flex;
          align-items: flex-start;
          gap: 15px;
        }

        .feature-icon {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 40px;
          height: 40px;
          background: linear-gradient(135deg, #4158D0 0%, #C850C0 100%);
          border-radius: 50%;
          color: white;
          flex-shrink: 0;
        }

        .feature-text h4 {
          font-size: 1.1rem;
          font-weight: 600;
          margin-bottom: 5px;
        }

        .feature-text p {
          font-size: 0.9rem;
          color: #666;
        }

        .beta-form {
          display: flex;
          flex-direction: column;
          gap: 15px;
          margin-bottom: 20px;
          max-width: 500px;
        }

        @media (min-width: 576px) {
          .beta-form {
            flex-direction: row;
          }
        }

        .beta-form input {
          flex: 1;
          padding: 12px 20px;
          border-radius: 8px;
          border: 1px solid #ddd;
          font-size: 1rem;
        }

        .beta-form button {
          display: flex;
          align-items: center;
          justify-content: center;
          white-space: nowrap;
        }

        .beta-note {
          font-size: 0.85rem;
          color: #777;
        }

        .beta-program-image {
          flex: 1;
          position: relative;
          display: flex;
          justify-content: center;
          align-items: center;
        }

        .image-container {
          position: relative;
          width: 100%;
          max-width: 500px;
        }

        .image-container img {
          width: 100%;
          height: auto;
          border-radius: 12px;
          box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
        }

        .floating-badge {
          position: absolute;
          background: white;
          padding: 10px 15px;
          border-radius: 8px;
          box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
          font-size: 0.9rem;
          font-weight: 600;
        }

        .badge-1 {
          top: 10%;
          left: -5%;
        }

        .badge-2 {
          bottom: 15%;
          right: -5%;
        }

        @media (max-width: 991px) {
          .badge-1, .badge-2 {
            display: none;
          }
        }
      `}</style>
    </div>
  );
};

export default BetaProgramBanner;