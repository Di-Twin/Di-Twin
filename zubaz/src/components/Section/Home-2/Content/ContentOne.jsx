"use client";
import { useEffect, useState } from "react";
import CountUp from "react-countup";
const ContentSectionOne = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const section = document.getElementById("zubuz-counter");
      if (section) {
        const rect = section.getBoundingClientRect();
        const isVisible = rect.top <= window.innerHeight && rect.bottom >= 0;
        setIsVisible(isVisible);
      }
    };

    window.addEventListener("scroll", handleScroll);

    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);
  return (
    <div id="why-us" className="section zubuz-section-padding2">
      <div id="zubuz-counter"></div>
      <div className="container">
        <div className="row">
          <div className="col-lg-5">
            <div className="zubuz-v2-thumb thumb-mr">
              <img src="/images/v2/thumb-v2-1.png" alt="" />
              <div className="zubuz-v2-thumb-shape">
                <img src="/images/v2/shape3-v2.png" alt="" />
              </div>
            </div>
          </div>
          <div className="col-lg-7">
            <div className="zubuz-default-content">
              <h2>The Chronic Disease Epidemic</h2>
              <p>
                Chronic diseases like diabetes, heart disease, and hypertension
                affect millions worldwide. These conditions often go unnoticed
                until it&apos;s too late, leading to severe health complications.
                Prevention and early detection are crucial to reducing risks.
              </p>
              <div className="zubuz-extara-mt">
                <div className="zubuz-counter-wrap">
                  <div className="zubuz-counter-data">
                    <h2 className="zubuz-counter-number">
                      <span data-percentage="99" className="zubuz-counter">
                        {isVisible ? <CountUp end={65} duration={5} /> : 65}
                      </span>
                      %
                    </h2>
                    <p>of adults worldwide suffer from chronic diseases</p>
                  </div>
                  <div className="zubuz-counter-data">
                    <h2 className="zubuz-counter-number">
                      <span data-percentage="3.5" className="zubuz-counter">
                        {isVisible ? <CountUp end={41} duration={5} /> : 41}
                      </span>
                      M
                    </h2>
                    <p>deaths annually caused by chronic illnesses</p>
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

export default ContentSectionOne;
