"use client";
import Link from "next/link";
import Accordion from "react-bootstrap/Accordion";

const Faq = () => {
  return (
    <div className="scetion zubuz-section-padding2 white-bg">
      <div className="container">
        <div className="row">
          <div className="col-lg-7 order-lg-2">
            <div className="zubuz-default-content">
              <h2>Smarter Health Insights for a Better You</h2>
              <p>
                DTwin transforms your health with{" "}
                <strong>AI-powered scores</strong> that analyze{" "}
                <strong>
                  your daily habits, metabolism, and overall wellness
                </strong>{" "}
                .
              </p>
              <p>
                Our intelligent system tracks your{" "}
                <strong>
                  heart rate, sleep patterns, activity levels, and nutrition
                </strong>{" "}
                , delivering <strong>personalized recommendations</strong> to
                help you stay on top of your health.
              </p>
              <div className="zubuz-extara-mt">
                <Link className="zubuz-default-btn" href="contact-us">
                  <span>Start Your Health Journey</span>
                </Link>
              </div>
            </div>
          </div>
          <div className="col-lg-5">
            <div className="zubuz-accordion-wrap">
              <Accordion defaultActiveKey="0" flush>
                <Accordion.Item eventKey="0">
                  <Accordion.Header>Health Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Your all-in-one wellness metric!</strong> We analyze{" "}
                    <strong>
                      age, weight, height, sleep, and activity levels
                    </strong>{" "}
                    to generate a <strong>real-time health score</strong> that
                    reflects your overall well-being.
                  </Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey="1">
                  <Accordion.Header>Sleep Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Quality sleep, better recovery!</strong>
                    Our AI examines{" "}
                    <strong>light, deep, and REM sleep cycles</strong>,
                    providing insights to{" "}
                    <strong>
                      optimize your rest and improve energy levels
                    </strong>
                    .
                  </Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey="2">
                  <Accordion.Header>Activity Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Stay active, stay healthy!</strong>
                    We track{" "}
                    <strong>
                      calories burned, cardio load, and BMR
                    </strong> using <strong>wearable integration</strong> to
                    assess your daily physical activity and recommend
                    personalized fitness goals.
                  </Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey="3">
                  <Accordion.Header>Food Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Smart nutrition for a healthier you!</strong>
                    We analyze your{" "}
                    <strong>
                      calorie intake, sugar, carbs, fat, and fiber
                    </strong>{" "}
                    to offer AI-driven food insights that{" "}
                    <strong>help you make better dietary choices</strong>.
                  </Accordion.Body>
                </Accordion.Item>
              </Accordion>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Faq;
