const ContentSectionOne = () => {
  return (
    <div id="features" className="section zubuz-section-padding2 white-bg">
      <div className="container">
        <div className="row">
          <div className="col-lg-5">
            <div className="zubuz-thumb thumb-pr">
              <img src="/images/v1/mocup01.png" alt="" />
              <div className="zubuz-thumb-card">
                <img src="/images/v1/card1.png" alt="" />
              </div>
            </div>
          </div>
          <div className="col-lg-7 d-flex align-items-center">
            <div className="zubuz-default-content">
              <h2>Stay Ahead of Health Risks</h2>
              <p>
                <strong>AI-driven predictions</strong> detect potential health
                issues early by analyzing your lifestyle, vitals, and wearable
                data.
              </p>
              <div className="zubuz-extara-mt">
                <p>
                  <span className="font-semibold">Early Detection:</span> AI
                  analyzes <strong>sleep, nutrition, and activity</strong> to
                  flag risks like diabetes and heart disease.
                </p>
                <p>
                  <span className="font-semibold">
                    Personalized Health Insights:
                  </span>{" "}
                  Get <strong>personalized reports</strong> and proactive
                  wellness tips to stay healthy.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ContentSectionOne;
