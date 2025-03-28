import Marquee from "react-fast-marquee";

const BrandSection = () => {
  return (
    <div className="section dark-bg" style={{ padding: "20px 0" }}>
      <div className="container">
        <div className="row align-items-center" style={{ margin: "0" }}>
          <div className="col-lg-5" style={{ paddingBottom: "10px" }}>
            <div className="zubuz-brand-logo-content" style={{ margin: "0" }}>
              <h3
                style={{ fontSize: "1.2rem", lineHeight: "1.4", margin: "0", fontWeight: "700" }}
              >
                Over 20+ smartwatches, CGMs, and smart rings work seamlessly
                with DTwin
              </h3>
            </div>
          </div>
          <div className="col-lg-7">
            <Marquee speed="30" className="zubuz-brand-slider" gradient={false}>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_1.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_2.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_3.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_4.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_5.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_6.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
            </Marquee>
            <Marquee
              speed="30"
              direction="right"
              className="zubuz-brand-slider"
              style={{ marginTop: "10px" }}
              gradient={false}
            >
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_1.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_2.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_3.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_4.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_5.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
              <div className="zubuz-brand-item" style={{ margin: "0 10px" }}>
                <img
                  src="/images/v1/b_6.png"
                  alt=""
                  style={{ maxHeight: "16px", width: "auto" }}
                />
              </div>
            </Marquee>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BrandSection;
