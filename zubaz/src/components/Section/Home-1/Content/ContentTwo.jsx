const ContentSectionTwo = () => {
  return (
    <div className="section zubuz-section-padding5 white-bg">
      <div className="container">
        <div className="row">
          <div className="col-lg-5 order-lg-2">
            <div className="zubuz-thumb thumb-pl">
              <img src="/images/v1/mocup2.png" alt="" />
              <div className="zubuz-thumb-card2">
                <img src="/images/v1/card2.png" alt="" />
              </div>
            </div>
          </div>
          <div className="col-lg-7 d-flex align-items-center">
            <div className="zubuz-default-content">
              <h2>AI-Powered Real-Time Diet Plans</h2>
              <p>
                Get <strong>personalized meal recommendations</strong> based on
                your health data, activity, and dietary needs—<strong>instantly!</strong>
              </p>
              <div className="zubuz-extara-mt">
                <div className="zubuz-iconbox-wrap-left">
                  <div className="zubuz-iconbox-icon">
                    <img src="/images/v1/icon1.png" alt="" />
                  </div>
                  <div className="zubuz-iconbox-data">
                    <span>Smart Nutrition</span>
                    <p>
                      AI analyzes{" "}
                      <strong>calories, macros & meal timing</strong> to keep
                      you on track.
                    </p>
                  </div>
                </div>
                <div className="zubuz-iconbox-wrap-left">
                  <div className="zubuz-iconbox-icon">
                    <img src="/images/v1/icon2.png" alt="" />
                  </div>
                  <div className="zubuz-iconbox-data">
                    <span>Personalized Meals</span>
                    <p>
                      Get <strong>tailored diet plans</strong> that match your
                      lifestyle & health goals.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ContentSectionTwo;
