const ContentSectionTwo = () => {
  return (
    <div className="section zubuz-section-padding5">
      <div className="container">
        <div className="row">
          <div className="col-lg-5 order-lg-2">
            <div className="zubuz-v2-thumb thumb-ml">
              <img src="/images/v2/thumb-v2-2.png" alt="" />
            </div>
          </div>
          <div className="col-lg-7">
            <div className="zubuz-default-content">
              <h2>The Future of Preventive Healthcare</h2>
              <p>
                Chronic diseases are a growing epidemic, but with the power of
                <strong>
                  {" "}
                  AI, real-time monitoring, and predictive analytics
                </strong>
                , DTwin is changing the way we manage health. Our platform{" "}
                <strong>does more than just track data</strong>—it
                <strong>
                  {" "}
                  helps you prevent, predict, and personalize
                </strong>{" "}
                your health journey.
              </p>
              <div className="zubuz-extara-mt">
                <div className="zubuz-iconbox-wrap-left">
                  <div className="zubuz-iconbox-icon none-bg">
                    <img src="/images/v2/check.png" alt="" />
                  </div>
                  <div className="zubuz-iconbox-data">
                    <span>AI-Powered Disease Prediction</span>
                    <p>
                      Detect risks for diabetes, heart disease, and more—before
                      symptoms appear.
                    </p>
                  </div>
                </div>
                <div className="zubuz-iconbox-wrap-left">
                  <div className="zubuz-iconbox-icon none-bg">
                    <img src="/images/v2/check.png" alt="" />
                  </div>
                  <div className="zubuz-iconbox-data">
                    <span>Lab Report & Prescription Analysis</span>
                    <p>
                      Instantly analyze medical reports and prescriptions with
                      AI for better insights.
                    </p>
                  </div>
                </div>
                <div className="zubuz-iconbox-wrap-left">
                  <div className="zubuz-iconbox-icon none-bg">
                    <img src="/images/v2/check.png" alt="" />
                  </div>
                  <div className="zubuz-iconbox-data">
                    <span>All-in-One Health Ecosystem</span>
                    <p>
                      A single platform to manage chronic conditions, track
                      fitness, and improve wellness.
                    </p>
                  </div>
                </div>
              </div>
              <div className="zubuz-extara-mt">
                <a className="zubuz-default-btn" href="contact-us">
                  <span>Experience the Future of Health</span>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ContentSectionTwo;
