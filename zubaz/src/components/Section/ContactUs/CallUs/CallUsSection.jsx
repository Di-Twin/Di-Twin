const CallUsSection = () => {
  return (
    <div className="section dark-bg zubuz-section-padding6 dark-bg">
      <div className="container">
        <div className="row">
          <div className="col-lg-4 col-md-6">
            <a href="mailto:name@email.com">
              <div className="zubuz-iconbox-wrap-left text-center-lg rt-mb-24">
                <div className="zubuz-iconbox-icon">
                  <img src="/images/icon/email3.svg" />
                </div>
                <div className="zubuz-iconbox-data light">
                  <h3>Email us</h3>
                  <p>
                    example@gmail.com
                    <br />
                    example@gmail.com
                  </p>
                </div>
              </div>
            </a>
          </div>
          <div className="col-lg-4 col-md-6">
            <div className="zubuz-iconbox-wrap-left text-center-lg rt-mb-24">
              <div className="zubuz-iconbox-icon">
                <img src="/images/icon/map2.svg" />
              </div>
              <div className="zubuz-iconbox-data light">
                <h3>Our office address</h3>
                <p>
                  Chennai
                  <br /> Tamilnadu.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CallUsSection;
