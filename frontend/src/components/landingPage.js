import React from "react";

export function LandingPage({ gov, pro, con, util, reg }) {
  return (
    <div className="container">
      <div className="landing">
        <h1>LANDING PAGE</h1>
        <h3>Select Participant</h3>
        <div id="participant">
          <button type="button" class="btn btn-secondary" id="governor" onClick={gov}>Governor</button>
          <button type="button" class="btn btn-secondary" id="prosumer" onClick={pro}>Prosumer</button>
          <button type="button" class="btn btn-secondary" id="consumer" onClick={con}>Consumer</button>
          <button type="button" class="btn btn-secondary" id="utility" onClick={util}>Utility</button>
          <button type="button" class="btn btn-secondary" id="regulator" onClick={reg}>Regulator</button>
        </div>
      </div>
    </div>
  );
}
